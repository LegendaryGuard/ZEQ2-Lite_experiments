git add --all
if [ $? -eq 0 ]
then
  echo "Success: GIT ADDED."
  exit 0
else
  echo "Failure: GIT CANNOT ADD" >&2
  exit 1
fi
git commit -m "Update SVN Hourly" 
if [ $? -eq 0 ]
then
  echo "Success: GIT COMMITED, PUSHING..."
  git push
  exit 0
else
  echo "Failure: GIT CANNOT COMMIT" >&2
  exit 1
fi