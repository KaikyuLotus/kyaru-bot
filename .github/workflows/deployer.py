#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from random import choice

from telegram import Bot

mode = sys.argv[1]

token = os.environ["BOT_TOKEN"]
actor = os.environ["GITHUB_ACTOR"]
commit_message = os.environ["COMMIT_MESSAGE"]
short_commit = os.environ["GITHUB_SHA"][:7]
target_chat_ids = os.environ["TARGET_CHAT_IDS"].split("\n")
owner_username = "@KaikyuLotus"

# Stickers
success_stickers = [
    "CAACAgQAAxkBAAMSXizBH6EVAcELC6oDWD_TEeXZPsIAAuIBAAK6gRoGPKkaIcuBR1MYBA",
]

fail_stickers = [
    "CAACAgUAAxkBAAMPXizAmFazxh4eyBrwPV477f9sNVgAAmgAAwM94R-m0c-xo2e6rxgE",
]

bot = Bot(token)


def check_analyzer_output():
    issues = {}
    critical_issues_count = 0
    issues_count = 0

    for line in sys.stdin.readlines():
        info = line.strip().split("|")
        severity = info[0]
        issue_type = info[1]
        issue_specific_type = info[2]
        issue_file = info[3]
        issue_line = info[4]
        issue_column = info[5]
        issue_length = info[6]
        issue_description = info[7]

        if issue_file not in issues:
            issues[issue_file] = {}

        if severity not in issues[issue_file]:
            issues[issue_file][severity] = {}

        if issue_type not in issues[issue_file][severity]:
            issues[issue_file][severity][issue_type] = []

        issue = {
            "issue": issue_specific_type,
            "file": issue_file,
            "line": issue_line,
            "column": issue_column,
            "length": issue_length,
            "description": issue_description
        }

        if issue_type != "LINT":
            critical_issues_count += 1

        issues[issue_file][severity][issue_type].append(issue)
        issues_count += 1

    for file, severities in issues.items():
        print(f"File {file}:")
        for severity, issue_types in severities.items():
            print(f" {severity}")
            for issue_type, type_issues in issue_types.items():
                print(f"  {issue_type}")
                for type_issue in sorted(type_issues, key=lambda x: x['line']):
                    print(f"   Line {type_issue['line']}: {type_issue['description']}")

    if critical_issues_count > 0:
        message = f"{critical_issues_count} issues on {issues_count} are critical, cannot continue with the build"
        print(f"\n\n!! {message} !!")
        quality_check_failed(issues_count, critical_issues_count)
        exit(1)


def broadcast_message(message, failed=True):
    sticker = choice(fail_stickers if fail_stickers else success_stickers)
    print(message)
    for target_chat_id in target_chat_ids:
        bot.send_message(target_chat_id, message, parse_mode="markdown")
        bot.send_sticker(target_chat_id, sticker)


def quality_check_failed(issues_count: int, non_lint_issues_count: int):
    broadcast_message(f"{owner_username} I've found too many critical issues in my last code update:\n\n"
                      f"*{non_lint_issues_count}* critical issues\n"
                      f"*{issues_count}* total issues\n\n"
                      f"This is outrageous and I'll refuse to compile until you fix all the critical issues.")


def build_failed():
    broadcast_message("Dart build failed, please check the logs.")


def deploy_failed():
    broadcast_message("GitHub deploy failed, please check the logs.")


def build_succeeded():
    broadcast_message(f"New commit (`{short_commit}`) on `develop` from `@{actor}`:\n"
                      f"\"`{commit_message}`\"\n\n"
                      f"Build succeeded ~")


def main():
    if "DISABLE_TELEGRAM" in os.environ and os.environ["DISABLE_TELEGRAM"].lower() == "true":
        return

    if mode == "check_analyzer_output":
        return check_analyzer_output()

    if mode == "deploy_failed":
        return deploy_failed()

    if mode == "build_failed":
        return build_failed()

    if mode == "build_succeeded":
        return build_succeeded()

    raise NotImplementedError(f"Mode '{mode}' is not implemented.")


if __name__ == "__main__":
    main()
