function stopGit()
{
  echo "NO NEW SVN UPDATE, SKIPPING..." >&2

  repo=$GITHUB_REPOSITORY # owner_repo/repo_name

  echo "Workflow ID: ${{ github.run_id }}"
  echo "Organization/User: $org"
  echo "Repository: $repo"

  # Get workflow IDs
  workflow_ids=($(gh api repos/$repo/actions/workflows | jq '.workflows[] | select(.["state"] | .id'))

  for workflow_id in "${workflow_ids[@]}"
  do
    echo "Listing runs for the workflow ID $workflow_id"
    run_ids=( $(gh api repos/$repo/actions/workflows/$workflow_id/runs --paginate | jq '.workflow_runs[].id') )
    for run_id in "${run_ids[@]}"
    do
      echo "Deleting Run ID $run_id"
      gh api repos/$repo/actions/runs/$run_id -X DELETE >/dev/null
    done
  done
}

cd Source
declare svnrevinfo=$( { svn info --revision HEAD --show-item revision; } )
declare svninfodesc=$( { svn log -r HEAD; } )
let svnrevinfominus=${svnrevinfo}-1
svn diff -r ${svnrevinfominus} > diff.patch
cd ..
patch < Source/diff.patch
git add Source
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