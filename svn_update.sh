function stopGit()
{
  echo "NO NEW SVN UPDATE, SKIPPING..." >&2

  # Get workflow IDs with status "disabled_manually"
  workflow_ids=($(gh api repos/$org/$repo/actions/workflows | jq '.workflows[] | select(.["state"] | contains("disabled_manually")) | .id'))

  for workflow_id in "${workflow_ids[@]}"
  do
    echo "Listing runs for the workflow ID $workflow_id"
    run_ids=( $(gh api repos/$org/$repo/actions/workflows/$workflow_id/runs --paginate | jq '.workflow_runs[].id') )
    for run_id in "${run_ids[@]}"
    do
      echo "Deleting Run ID $run_id"
      gh api repos/$org/$repo/actions/runs/$run_id -X DELETE >/dev/null
    done
  done
}

declare svnrevinfo=$( { svn info --revision HEAD --show-item revision; } )
declare svninfodesc=$( { svn log -r HEAD; } )
org=$GITHUB_ACTOR:$GITHUB_TOKEN
repo='ZEQ2-Lite'
git add --all
if [ $? -eq 0 ]
then
  echo "Success: GIT ADDED."
else
  stopGit
  exit 0
fi

git commit -m "SVN Revision ${svnrevinfo}" -m "${svninfodesc}"
if [ $? -eq 0 ]
then
  echo "Success: GIT COMMITED, PUSHING..."
  git push
  exit 0
else
  stopGit
  exit 0
fi