import re

def parse_changelog(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Pattern to match changelog entries
    pattern = re.compile(r'## \[(\d+\.\d+)\] - \d{4}-\d{2}-\d{2}\n((?:### .*\n(?:- .*\n)*)*)', re.DOTALL)
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

def update_lua_file(lua_file_path, changelog_table, current_version):
    with open(lua_file_path, 'r') as file:
        content = file.readlines()
    with open(lua_file_path, 'w') as file:
        found_changelog_table = False
        found_current_version = False
        for line in content:
            if line.strip().startswith("ChangelogHandler.Changelogs = {"):
                found_changelog_table = True
                file.write(changelog_table)
            elif found_changelog_table and line.strip() == "}":
                found_changelog_table = False
            elif line.strip().startswith("ChangelogHandler.CurrentVersion ="):
                found_current_version = True
                file.write(f'ChangelogHandler.CurrentVersion = "{current_version}"\n')
            else:
                file.write(line)

        if not found_changelog_table:
            file.write(changelog_table)
        if not found_current_version:
            file.write(f'ChangelogHandler.CurrentVersion = "{current_version}"\n')

if __name__ == "__main__":
    changelog_md_path = 'CHANGELOG.md'
    lua_file_path = 'lua/changelog_handler/changelog_handler_server.lua'  # Adjusted file path

    changelog_entries = parse_changelog(changelog_md_path)
    if changelog_entries:
        current_version = changelog_entries[0][0]  # Get the latest version from the changelog entries
        changelog_table = generate_lua_table(changelog_entries)
        update_lua_file(lua_file_path, changelog_table, current_version)
    else:
        print("No changelog entries found.")
