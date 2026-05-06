#!/usr/bin/env python3
import os
import re
import secrets
import subprocess
from pathlib import Path
from tempfile import NamedTemporaryFile

from flask import Flask, flash, redirect, render_template, request, session, url_for as flask_url_for


APP_TITLE = "SVN Admin"
PASSWD_FILE = Path(os.environ.get("SVN_PASSWD_FILE", "/etc/apache2/dav_svn.passwd"))
AUTHZ_FILE = Path(os.environ.get("SVN_AUTHZ_FILE", "/etc/apache2/dav_svn.authz"))
HTPASSWD_BIN = os.environ.get("HTPASSWD_BIN", "/usr/bin/htpasswd")
ADMIN_USERNAME = os.environ.get("SVN_ADMIN_UI_USER", "admin")
ADMIN_PASSWORD = os.environ.get("SVN_ADMIN_UI_PASSWORD", "")
SECRET_KEY = os.environ.get("SVN_ADMIN_UI_SECRET", secrets.token_hex(32))
ADMIN_UI_BASE_PATH = os.environ.get("SVN_ADMIN_UI_BASE_PATH", "").strip()
GROUP_NAMES = ("admins", "mechanical", "electrical", "business")
USERNAME_RE = re.compile(r"^[a-zA-Z0-9._-]{3,32}$")

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY
if ADMIN_UI_BASE_PATH:
    if not ADMIN_UI_BASE_PATH.startswith("/"):
        ADMIN_UI_BASE_PATH = f"/{ADMIN_UI_BASE_PATH}"
    ADMIN_UI_BASE_PATH = ADMIN_UI_BASE_PATH.rstrip("/")
app.config["APPLICATION_ROOT"] = ADMIN_UI_BASE_PATH or "/"
if ADMIN_UI_BASE_PATH:
    app.config["SESSION_COOKIE_PATH"] = ADMIN_UI_BASE_PATH


def url_for(endpoint, **values):
    return f"{ADMIN_UI_BASE_PATH}{flask_url_for(endpoint, **values)}"


@app.context_processor
def inject_url_for():
    return {"url_for": url_for}


def require_admin_password():
    if not ADMIN_PASSWORD:
        raise RuntimeError("SVN_ADMIN_UI_PASSWORD must be set before starting the admin UI.")


def list_users():
    if not PASSWD_FILE.exists():
        return []

    users = []
    for line in PASSWD_FILE.read_text(encoding="utf-8").splitlines():
        if ":" in line:
            users.append(line.split(":", 1)[0].strip())
    return sorted({user for user in users if user})


def read_authz():
    text = AUTHZ_FILE.read_text(encoding="utf-8") if AUTHZ_FILE.exists() else ""
    lines = text.splitlines()
    groups = {name: [] for name in GROUP_NAMES}

    in_groups = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_groups = stripped.lower() == "[groups]"
            continue
        if not in_groups or "=" not in line:
            continue

        key, value = line.split("=", 1)
        group_name = key.strip()
        if group_name not in groups:
            continue
        members = [member.strip() for member in value.split(",") if member.strip()]
        groups[group_name] = members

    return text, groups


def write_authz(updated_groups):
    original_text, _ = read_authz()
    lines = original_text.splitlines()
    output = []
    in_groups = False
    groups_written = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if in_groups and not groups_written:
                output.extend(format_groups(updated_groups))
                groups_written = True
            in_groups = stripped.lower() == "[groups]"
            output.append(line)
            continue

        if in_groups:
            continue

        output.append(line)

    if not lines:
        output.append("[groups]")
        output.extend(format_groups(updated_groups))
        groups_written = True
    elif not groups_written:
        output.append("")
        output.append("[groups]")
        output.extend(format_groups(updated_groups))

    new_text = "\n".join(output).rstrip() + "\n"
    with NamedTemporaryFile("w", delete=False, encoding="utf-8", dir=str(AUTHZ_FILE.parent)) as handle:
        handle.write(new_text)
        temp_name = handle.name
    os.replace(temp_name, AUTHZ_FILE)


def format_groups(groups):
    formatted = []
    for group_name in GROUP_NAMES:
        members = ",".join(sorted(set(groups.get(group_name, []))))
        formatted.append(f"{group_name} = {members}")
    return formatted


def create_or_reset_user(username, password):
    if not PASSWD_FILE.exists():
        PASSWD_FILE.touch(mode=0o640, exist_ok=True)

    result = subprocess.run(
        [HTPASSWD_BIN, "-b", PASSWD_FILE.as_posix(), username, password],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "htpasswd failed")


def update_groups(username, selected_groups):
    _, groups = read_authz()
    for group_name in GROUP_NAMES:
        members = set(groups.get(group_name, []))
        members.discard(username)
        if group_name in selected_groups:
            members.add(username)
        groups[group_name] = sorted(members)
    write_authz(groups)


def remove_user_everywhere(username):
    _, groups = read_authz()
    for group_name in GROUP_NAMES:
        groups[group_name] = [member for member in groups.get(group_name, []) if member != username]
    write_authz(groups)

    if PASSWD_FILE.exists():
        kept_lines = []
        for line in PASSWD_FILE.read_text(encoding="utf-8").splitlines():
            if not line.startswith(f"{username}:"):
                kept_lines.append(line)
        PASSWD_FILE.write_text("\n".join(kept_lines).rstrip() + ("\n" if kept_lines else ""), encoding="utf-8")


def current_state():
    users = list_users()
    _, groups = read_authz()
    user_rows = []
    for username in users:
        user_rows.append(
            {
                "username": username,
                "groups": [group for group in GROUP_NAMES if username in groups.get(group, [])],
            }
        )
    return user_rows


@app.before_request
def ensure_config():
    require_admin_password()


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
            session["admin_logged_in"] = True
            return redirect(url_for("index"))
        flash("Invalid admin credentials.", "error")
    return render_template("login.html", title=f"{APP_TITLE} Login")


@app.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/", methods=["GET"])
def index():
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))
    return render_template("index.html", title=APP_TITLE, users=current_state(), group_names=GROUP_NAMES)


@app.route("/users", methods=["POST"])
def create_user():
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))

    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")
    selected_groups = {group for group in GROUP_NAMES if request.form.get(group) == "on"}

    if not USERNAME_RE.match(username):
        flash("Username must be 3-32 chars and use only letters, numbers, dot, underscore, or dash.", "error")
        return redirect(url_for("index"))
    if len(password) < 12:
        flash("Password must be at least 12 characters.", "error")
        return redirect(url_for("index"))

    try:
        create_or_reset_user(username, password)
        update_groups(username, selected_groups)
        flash(f"Saved user '{username}'.", "success")
    except Exception as exc:
        flash(str(exc), "error")
    return redirect(url_for("index"))


@app.route("/users/<username>/password", methods=["POST"])
def reset_password(username):
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))

    password = request.form.get("password", "")
    if len(password) < 12:
        flash("Password must be at least 12 characters.", "error")
        return redirect(url_for("index"))

    try:
        create_or_reset_user(username, password)
        flash(f"Reset password for '{username}'.", "success")
    except Exception as exc:
        flash(str(exc), "error")
    return redirect(url_for("index"))


@app.route("/users/<username>/groups", methods=["POST"])
def save_groups(username):
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))

    selected_groups = {group for group in GROUP_NAMES if request.form.get(group) == "on"}
    try:
        update_groups(username, selected_groups)
        flash(f"Updated groups for '{username}'.", "success")
    except Exception as exc:
        flash(str(exc), "error")
    return redirect(url_for("index"))


@app.route("/users/<username>/delete", methods=["POST"])
def delete_user(username):
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))

    if username == ADMIN_USERNAME:
        flash("Refusing to delete the admin UI login user from the SVN files.", "error")
        return redirect(url_for("index"))

    try:
        remove_user_everywhere(username)
        flash(f"Deleted '{username}' from passwd and authz files.", "success")
    except Exception as exc:
        flash(str(exc), "error")
    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=int(os.environ.get("SVN_ADMIN_UI_PORT", "5050")))
