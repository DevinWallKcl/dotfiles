DOTFILES_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$(dirname $DOTFILES_BIN_DIR)")"
CURRENT_WORKING_DIR=$(pwd)

if [ ! -d $WORKSPACE_DIR ]
then
    mkdir $WORKSPACE_DIR
fi

cd $WORKSPACE_DIR

repositories=(
    "git@github.com:KrazyCouponLady/web.git"
    "git@github.com:KrazyCouponLady/martini.git"
    "git@github.com:KrazyCouponLady/deals-mobile.git"
    "git@github.com:KrazyCouponLady/dealwizard.git"
    "git@github.com:KrazyCouponLady/krazydevs-static.git"
    "git@github.com:KrazyCouponLady/deal-formula.git"
)

echo "==== Cloning repositories ====\n"

for repo in "${repositories[@]}"
do
    folder_name=$(basename $repo .git)
    repo_path="$WORKSPACE_DIR/$folder_name"

    if [ ! -d $repo_path ]
    then
        git clone $repo
        echo "\n"
    fi
done

cd $CURRENT_WORKING_DIR
echo "Cloning complete.\n"
