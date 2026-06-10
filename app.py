from flask import Flask, render_template, request, redirect, jsonify, Response
from pathlib import Path
from passlib.apache import HtpasswdFile
import yaml

app = Flask(__name__)

DATA_DIR = Path("/taskmaster")
TASKS_FILE = DATA_DIR / "tasks.yaml"
COMPLETED_FILE = DATA_DIR / "completed.yaml"
URGENT_FILE = DATA_DIR / "urgent.yaml"
HTPASSWD_FILE = DATA_DIR / ".htpasswd"


def ensure_data_files():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    # Do not seed or modify YAML contents here.
    # deploy-taskmaster.sh is responsible for installing the user's supplied YAMLs
    # into /taskmaster if the files are missing.
    for path in [TASKS_FILE, COMPLETED_FILE, URGENT_FILE]:
        if not path.exists():
            save_list(path, [])


def load_list(path):
    try:
        if not path.exists():
            return []

        with open(path, "r") as f:
            data = yaml.safe_load(f)

        if isinstance(data, list):
            return [str(item) for item in data if str(item).strip()]

        return []
    except Exception:
        return []


def save_list(path, items):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        yaml.safe_dump(items, f, default_flow_style=False, sort_keys=False)


def get_list_by_name(list_name):
    if list_name == "urgent":
        return URGENT_FILE
    if list_name == "tasks":
        return TASKS_FILE
    if list_name == "completed":
        return COMPLETED_FILE

    return None


def auth_required():
    return Response(
        "Authentication required\n",
        401,
        {"WWW-Authenticate": 'Basic realm="Taskmaster"'}
    )


def check_auth(username, password):
    if not HTPASSWD_FILE.exists():
        return False

    try:
        ht = HtpasswdFile(str(HTPASSWD_FILE))
        return ht.check_password(username, password)
    except Exception:
        return False


@app.before_request
def before_request():
    ensure_data_files()

    if request.path == "/healthz":
        return None

    auth = request.authorization

    if not auth or not check_auth(auth.username, auth.password):
        return auth_required()

    return None


@app.route("/")
def schedule():
    return render_template(
        "james_schedule.html",
        today="today",
        urgent_tasks=load_list(URGENT_FILE),
        tasks=load_list(TASKS_FILE),
        completed_tasks=load_list(COMPLETED_FILE),
        command="fuck you james"
    )


@app.post("/tasks/<list_name>")
def add_task(list_name):
    path = get_list_by_name(list_name)

    if path is None:
        return jsonify({"status": "error", "message": "Unknown list"}), 404

    task = request.form.get("task")
    if task and task.strip():
        items = load_list(path)
        items.append(task.strip())
        save_list(path, items)

    return redirect("/")


@app.delete("/tasks/<list_name>/<int:index>")
def delete_task(list_name, index):
    path = get_list_by_name(list_name)

    if path is None:
        return jsonify({"status": "error", "message": "Unknown list"}), 404

    items = load_list(path)

    if 0 <= index < len(items):
        items.pop(index)
        save_list(path, items)

    return jsonify({"status": "ok", "tasks": items})


@app.post("/tasks/<list_name>/<int:index>/complete")
def complete_task(list_name, index):
    # Completing either urgent or medium-term tasks moves the item into completed.yaml,
    # which is displayed as "Things I Have Already Done and Want Nick Cole to Know About."
    if list_name not in ["urgent", "tasks"]:
        return jsonify({"status": "error", "message": "Only urgent or medium-term tasks can be completed"}), 404

    source_path = get_list_by_name(list_name)
    source_items = load_list(source_path)
    completed_items = load_list(COMPLETED_FILE)

    if 0 <= index < len(source_items):
        completed_items.append(source_items.pop(index))
        save_list(source_path, source_items)
        save_list(COMPLETED_FILE, completed_items)

    return redirect("/")


@app.post("/tasks/completed/<int:index>/restore")
def restore_completed_task(index):
    completed_items = load_list(COMPLETED_FILE)
    task_items = load_list(TASKS_FILE)

    if 0 <= index < len(completed_items):
        task_items.append(completed_items.pop(index))
        save_list(COMPLETED_FILE, completed_items)
        save_list(TASKS_FILE, task_items)

    return redirect("/")


@app.route("/healthz")
def healthz():
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=443,
        ssl_context=(
            "/etc/letsencrypt/live/taskmaster.vixal.net/fullchain.pem",
            "/etc/letsencrypt/live/taskmaster.vixal.net/privkey.pem"
        )
    )
