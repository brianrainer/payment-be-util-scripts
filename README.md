# Payment BE Util Scripts

This repo is dedicated to host utility scripts that helps with our day-to-day tasks as payment backend engineers.


### Payment Release Branches & JIRA Tickets Creation Script

#### File
`tvlk-payment-release.sh`

#### Goal
This script is to create release branches and their respective JIRA tickets and save it in `release_branch.txt` file. It will automatically create a list of release branches and their related JIRA tickets like the following;

```
`[service-name]/release/yyyy-mm-dd` [JIRA_ticket_URL]
```

You can immediately copy-and-paste it to announce the release branches while brewing a cup of coffee/tea.

#### Usage

- Save the `tvlk-payment-release.sh` script by **Right-click -> "Save Link As..."** and save it in the root folder of `old-monorepo`
- Make it executable by executing `sudo chmod u+x tvlk-payment-release.sh`
- Run it with `./tvlk-payment-release.sh` and all the required flags.
- To see the manual, type `./tvlk-payment-release.sh --help`.


Feel free to contribute!