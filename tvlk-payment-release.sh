#!/bin/bash

# dependency check
if command -v python3 >/dev/null 2>&1 ; then
	printf "";
else
	printf "ERROR: Dependecy: python3 not installed. Please install using: sudo apt install python3\nExiting... (code:1)\n" 1>&2;
	exit 1;
fi


release_date="";
commit_base="";
user_id="";      # you can directly assign with your personal JIRA user ID or use the -u option when running the script
API_token="";    # you can directly assign with your personal JIRA API token or use the -t option when running the script
email="";        # you can directly assign with your personal Travleoka email address or use the -e option when running the script


while test $# -gt 0; do
	case "$1" in
		-h|--help)
			printf "\n";
			printf "==============================================================\n"
			printf "TVLK PAYMENT TEAM RELEASE BRANCH & JIRA TICKET CREATION SCRIPT\n";
			printf "==============================================================\n\n"
			printf "TL;DR: This script is for lazy engineers (I know who you are) who don't want to spend too much time creating release branches and JIRA tickets.\n\n";
			printf "This is expanded from Ardhinata's release script, but will automate both release branches creation and JIRA tickets in one go. WOO-HOO!\n\n";
			printf "How to use this release script:\n\n";
			printf " 1) Save this script to old-monorepo root folder.\n";
			printf " 2) Make sure the script is executable (by executing: sudo chmod u+x tvlk-payment-release.sh)\n";
			printf " 3) (Ab)use it! by executing:\n";
			printf "      ./tvlk-payment-release.sh -b|--base <commit_base_SHA> -d|--date <release_date> \\ \n";
			printf "                                -u|--user <user_ID> -e|--email <email_address> -t|--token <API_token> \n";
			printf "    For example:\n";
			printf "      ./tvlk-payment-release.sh -b 8d3732efc790354491a1ab73db127ea8c693cb6c \\ \n";
			printf "                                -d 2019-02-19 -u yusuf.putra -e yusuf.putra@traveloka.com -t 12345678\n\n";			
			printf " 4) You can retrieve the release branches and JIRA ticket URLs in release_branch.txt. It's already in Slack's format.\n";
			printf "    So, just copy-paste it and make a coffee.\n";
			printf "\n\n";
			printf "NOTE:\n";
			printf "=====\n";
			printf "1) Dependency of this script is python3. Make sure you have python3\n";
			printf "   installed on your computer before running this script.\n";
			printf "2) This will create only PG, PAYPGW, PAYPAPI, PAYWLT, POUT, PAYFCLT\n";
			printf "   PAYASGN, PAYCTX, PAYPOP, PAYOD release branches and JIRA tickets\n";
			printf "3) [ATTENTION] There's no date format checking, commit SHA check, email, userID, and API token check!\n";
			printf "   So, make sure you enter the correct information before running this script!\n\n"
			printf "WARNING: This scipt has been tested in creating all the 2019-02-19 release branches on Ubuntu 16.04. However, no guarantee it will run correctly on your computer.";
			printf " So, RUN IT AT YOUR OWN RISK.\n";
			exit 0;
			;;
		-d|--date)
			shift
			if test $# -gt 0; then
				release_date=$1				
			fi
			shift
			;;
		-b|--base)
			shift
			if test $# -gt 0; then
				commit_base=$1				
			fi
			shift
			;;
		-u|--user)
			shift
			if test $# -gt 0; then
				user_id=$1				
			fi
			shift
			;;
		-t|--token)
			shift
			if test $# -gt 0; then
				API_token=$1				
			fi
			shift
			;;
		-e|--email)
			shift
			if test $# -gt 0; then
				email=$1				
			fi
			shift
			;;
		*)
			break
			;;
	esac
done

if [ -z "$release_date" ] || [ -z "$commit_base" ] || [ -z "$email" ] || [ -z "$API_token" ]|| [ -z "$user_id" ]; then
	printf "FATAL ERROR: Release date, commit base, email, API token, and user ID must not be empty.\nFor manual type: ./tvlk-payment-release.sh --help\nExiting...\n" 1>&2;
	exit 1;
fi

echo "=================================================================================";
echo "Creating payment release branches and JIRA tickets with the following parameters:";
echo " - Release date = $release_date";
echo " - Commit base  = $commit_base";
echo " - User ID      = $user_id";
echo " - Email        = $email";
echo " - API token    = $API_token";
echo "";
echo "=================================================================================";
echo "";

# parameter check
while true; do
    read -p "(WARNING! Incorrect parameters will ruin your day!) Are you sure the above parameters correct? [yes/no] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


printf "Creating the file release_branch.txt";
touch -a release_branch.txt;
printf "..DONE\n";

printf "Checking out branch develop and pulling...\n";
git checkout develop;
git pull;
printf "Checking out and pulling branch develop...DONE\n\n";

for i in {PG,PAYPGW}; do
	echo "";
	echo "---";
	service=$(echo $i | tr '[A-Z]' '[a-z]');\
	echo "Creating branch release $service"; \
	git checkout -B $service/release/$release_date $commit_base; git push -u origin HEAD; \

	echo "Creating JIRA Task for $i"; \
	issue=$(curl -s -X POST \
		https://29022131.atlassian.net/rest/api/2/issue/ \
		-u "$email:$API_token" \
		-H 'Cache-Control: no-cache' \
		-H 'Content-Type: application/json' \
		-d "{\"fields\":{\"project\":{\"key\":\"PAY\"},\"summary\":\"[RELEASE] [$release_date] [$i] [S+F] [Main Release]\",\"description\":\"Change Log:\n1.\n\nTime and Version of Release:\nTime: Timestamp of actual release to production\nOld version:\nNew version:\n\nDependency:\n1. ..\n2. ..\n\nRisk:\nPlease give warning on this asana if your change have major risk (new major feature, service refactors, major config change, etc)\n\nReasons of Rollback:\nAdd reasons of rollback/ link to document if any\n...\n...\n\nNote:\nS = Service only\nF = Fetcher only\nS+F = Service and Fetcher\",\"issuetype\":{\"name\":\"Task\"},\"components\":[{\"id\":\"16403\"}],\"assignee\":{\"name\":\"$user_id\"}}}" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])");  \
	echo "\`$service/release/$release_date\` https://29022131.atlassian.net/browse/$issue" >> release_branch.txt;
	echo "$i DONE"
	echo "---"
done;

for i in {PAYPAPI,PAYWLT,POUT,PAYFCLT,PAYASGN,PAYCTX,PAYPOP,PAYOD,IPIPTC}; do
	echo "";
	echo "---";
	service=$(echo $i | tr '[A-Z]' '[a-z]');\
	echo "Creating branch release $service"; \
	git checkout -B $service/release/$release_date $commit_base; git push -u origin HEAD; \

	echo "Creating JIRA Task for $i"; \
	issue=$(curl -s -X POST \
		https://29022131.atlassian.net/rest/api/2/issue/ \
		-u "$email:$API_token" \
		-H 'Cache-Control: no-cache' \
		-H 'Content-Type: application/json' \
		-d "{\"fields\":{\"project\":{\"key\":\"PAY\"},\"summary\":\"[RELEASE] [$release_date] [$i] [S] [Main Release]\",\"description\":\"Change Log:\n1.\n\nTime and Version of Release:\nTime: Timestamp of actual release to production\nOld version:\nNew version:\n\nDependency:\n1. ..\n2. ..\n\nRisk:\nPlease give warning on this asana if your change have major risk (new major feature, service refactors, major config change, etc)\n\nReasons of Rollback:\nAdd reasons of rollback/ link to document if any\n...\n...\n\nNote:\nS = Service only\nF = Fetcher only\nS+F = Service and Fetcher\",\"issuetype\":{\"name\":\"Task\"},\"components\":[{\"id\":\"16403\"}],\"assignee\":{\"name\":\"$user_id\"}}}" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])");  \
	echo "\`$service/release/$release_date\` https://29022131.atlassian.net/browse/$issue" >> release_branch.txt;
	echo "$i DONE";
	echo "---";
done;
