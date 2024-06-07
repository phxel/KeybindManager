import re
import os

def parse_changelog(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    pattern = re.compile(r'## \[(\d+\.\d+(?:\.\d+)?(?:-\w+)*)\] - \d{4}-\d{2}-\d{2}\n((?:- .*\n)*)', re.DOTALL)
    entries = pattern.findall(content)

    changelog_entries = []
    for version, log in entries:
        log_lines = log.strip().split('\n')
        log_text = " ".join(line.strip('- ').strip() for line in log_lines if line.strip())
        changelog_entries.append((version, log_text))

    return changelog_entries

def generate_lua_table(changelog_entries):
    lua_table = "ChangelogHandler.Changelogs = {\n"
    for version, log in changelog_entries:
        lua_table += f'    {{version = "{version}", log = "{log}"}},\n'
    lua_table += "}\n"
    return lua_table

def update_lua_file(lua_file_path, changelog_entries, current_version):
    existing_content = ""
    if os.path.exists(lua_file_path):
        with open(lua_file_path, 'r') as file:
            existing_content = file.read()

    # Check if there is an existing ChangelogHandler table
    start_index = existing_content.find('ChangelogHandler = {')
    if start_index != -1:
        end_index = existing_content.rfind('}') + 1
        existing_changelog_table = existing_content[start_index:end_index]

        # Parse the existing changelog table and extract the current version
        pattern = r'ChangelogHandler\.CurrentVersion = "(\d+\.\d+(?:\.\d+)?(?:-\w+)*)"'
        match = re.search(pattern, existing_changelog_table)
        if match:
            existing_current_version = match.group(1)

            # Compare the current version with the new one
            if existing_current_version != current_version:
                print("New version detected. Updating changelog...")

                # Append new version entries to the existing table
                new_entries = generate_lua_table(changelog_entries)
                existing_content = existing_content[:start_index] + new_entries + existing_content[end_index:]

        else:
            print("Could not find current version in the existing changelog table.")

    else:
        print("No existing ChangelogHandler table found. Creating a new one...")
        lua_content = "ChangelogHandler = {}\n"
        lua_content += "ChangelogHandler.Changelogs = {\n"
        for version, log in changelog_entries:
            lua_content += f'    {{version = "{version}", log = "{log}"}},\n'
        lua_content += "}\n"
        lua_content += f'ChangelogHandler.CurrentVersion = "{current_version}"\n'

        existing_content = lua_content

    with open(lua_file_path, 'w') as file:
        file.write(existing_content)

if __name__ == "__main__":
    changelog_md_path = 'CHANGELOG.md'
    lua_file_path = 'lua/changelog_handler/changelog_handler_server.lua'
    changelog_entries = parse_changelog(changelog_md_path)
    if changelog_entries:
        current_version = changelog_entries[0][0]
        update_lua_file(lua_file_path, changelog_entries, current_version)
    else:
        print("No changelog entries found.")