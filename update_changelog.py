import re

def parse_changelog(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Pattern to match changelog entries
    pattern = re.compile(r'## \[(\d+\.\d+)\] - \d{4}-\d{2}-\d{2}\n(### .*\n(?:- .*\n)*)', re.DOTALL)
    entries = pattern.findall(content)

    changelog_entries = []
    for version, log in entries:
        log_lines = log.strip().split('\n')
        log_text = " ".join(line.strip('- ').strip() for line in log_lines if line.startswith('-'))
        changelog_entries.append((version, log_text))

    return changelog_entries

def generate_lua_table(changelog_entries):
    lua_table = "ChangelogHandler.Changelogs = {\n"
    for version, log in changelog_entries:
        lua_table += f'    {{version = "{version}", log = "{log}"}},\n'
    lua_table += "}\n"
    return lua_table

def update_lua_file(lua_file_path, changelog_table):
    with open(lua_file_path, 'r') as file:
        content = file.readlines()

    with open(lua_file_path, 'w') as file:
        inside_changelog_table = False
        for line in content:
            if line.strip().startswith("ChangelogHandler.Changelogs = {"):
                inside_changelog_table = True
                file.write(changelog_table)
            elif inside_changelog_table and line.strip() == "}":
                inside_changelog_table = False
            elif not inside_changelog_table:
                file.write(line)

if __name__ == "__main__":
    changelog_md_path = 'CHANGELOG.md'
    lua_file_path = 'lua/changelog_handler/changelog_handler_server.lua'

    changelog_entries = parse_changelog(changelog_md_path)
    changelog_table = generate_lua_table(changelog_entries)
    update_lua_file(lua_file_path, changelog_table)
