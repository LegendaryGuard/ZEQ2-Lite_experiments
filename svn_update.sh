function stopGit()
{
  echo "NO NEW SVN UPDATE, SKIPPING..." >&2

  REPO=$GITHUB_REPOSITORY # owner_repo/repo_name
  echo "Repository: $REPO"

  echo $GITHUB_TOKEN > token.txt

  # login
  gh auth login --with-token < token.txt

  # list workflows
  gh api -X GET /repos/$REPO/actions/workflows | jq '.workflows[] | .name,.id'

  # copy the ID of the workflow you want to clear and set it
  WORKFLOW_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO/actions/workflows | jq -r .workflows[0].id) &&
  echo $WORKFLOW_ID

  # list runs
  gh api -X GET /repos/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id'

  # delete runs (you'll have to run this multiple times if there's many because of pagination)
  gh api -X GET /repos/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | xargs -I{} gh api -X DELETE /repos/$REPO/actions/runs/{}

  echo "\nWorkflow ID: $WORKFLOW_ID"
}

cd Source
declare svnrevinfo=$( { svn info --revision HEAD --show-item revision; } )
declare svninfodesc=$( { svn log -r HEAD; } )
# let svnrevinfominus=${svnrevinfo}-1
# svn diff -r ${svnrevinfominus} > diff.patch
cd ..
# patch -p0 -R < Source/diff.patch
# rm -v Source/diff.patch
# git add Source/.svn
# if [ $? -eq 0 ]
# then
#   echo "Success: GIT ADDED."
# else
#   stopGit
#   exit 0
# fi

# git commit -m "SVN Revision ${svnrevinfo}: update .svn"
# if [ $? -eq 0 ]
# then
#   echo "Success: GIT COMMITED"
# else
#   stopGit
#   exit 0
# fi

git add --all
if [ $? -eq 0 ]
then
  echo "Success: GIT ADDED."
else
  stopGit
  # exit 0
fi

# to check files
ls -la
git status && git branch

git commit -m "SVN Revision ${svnrevinfo}" -m "${svninfodesc}"
if [ $? -eq 0 ]
then
  echo "Success: GIT COMMITED, PUSHING..."
  git push
  exit 0
else
  stopGit
  # exit 0
fi