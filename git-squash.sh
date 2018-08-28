#!/usr/bin/env sh


usage() {
	echo "NAME:"
	echo "\tgit-sqush - Squash several commits"

	echo "USAGE:"
	echo
	
	echo "\tgit squash --commit <commit>"
	echo "\tgit squash --diff <target-branch>"

	echo "DESCRIPTION:"
	echo

	echo "\tIn the first form, squash all commits before the <commit>."
	echo "\tIn another hand, the second form compute diff between <source-branch> (if not specified use HEAD) and <target-branch> and squash it."
	echo

	echo "OPTIONS:"
	echo
	echo "\t-c, --commit <commit>"
	echo "\t\tReset all changes till the <commit> to stage"
	echo

	echo "\t-d, --diff <target-branch>"
	echo "\t\tReset all changes between HEAD and <target-branch> to stage"
	echo

	echo "EAMPLE:"
	echo
	
	echo "\tgit squash --commit HEAD~1"
	echo "\tgit squash --commit 0987208108265812"
	echo "\tgit squash --diff master"
	echo
}

main(){
	if [ "$#" -lt 1 ]; then
		usage; exit 1
	fi
	
	local subcomand=$1; shift

	case $subcomand in
		"-h"|"--help")
			usage; exit 0
			;;
		"-c"|"--commit")
			squash_by_commit "$@";
			;;
		"-d"|"--diff")
			squash_by_diff "$@";
			;;
		*)
			usage; exit 1
			;;

	esac
}

squash_by_commit() {
	if [ "$#" -lt 1 ]; then
		echo "Missing argument <commit>"
		echo
		usage; exit 1
	fi

	local commit_expression="$1"

	git reset --soft $commit_expression

	exit 0
}

squash_by_diff() {
	if [ "$#" -lt 1 ]; then
		echo "Missing argument <target-branch>"
		echo
		usage; exit 1
	fi

	local source_branch="HEAD"
	local target_branch="$1"
	local timestamp=$(date +%s)
	
	local source_commits_file=$(echo "${TMPDIR}${timestamp}_${source_branch}.log")
	local target_commits_file=$(echo "${TMPDIR}${timestamp}_${target_branch}.log")

	git rev-list $source_branch > $source_commits_file
	git rev-list $target_branch > $target_commits_file

	local total_of_commits="$(diff $source_commits_file $target_commits_file | grep "<" | sed -n \$=)"

	git reset --soft HEAD~$total_of_commits

	exit 0
}
main "$@"
