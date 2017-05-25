#!/bin/bash -le

TRILINOS_BRANCH=$1

if [ -z $TRILINOS_BRANCH ]
then
  TRILINOS_BRANCH=develop
fi

export TRILINOS_UPDATED_PATH=${PWD}/trilinos-update
export TRILINOS_PRISTINE_PATH=${PWD}/trilinos-pristine

#rm -rf ${KOKKOS_PATH}
#rm -rf ${TRILINOS_UPDATED_PATH}
#rm -rf ${TRILINOS_PRISTINE_PATH}

#Already done:
if [ ! -d "${TRILINOS_UPDATED_PATH}" ]; then
  git clone https://github.com/trilinos/trilinos ${TRILINOS_UPDATED_PATH}
fi
if [ ! -d "${TRILINOS_PRISTINE_PATH}" ]; then
  git clone https://github.com/trilinos/trilinos ${TRILINOS_PRISTINE_PATH}
fi

cd ${TRILINOS_UPDATED_PATH}
git checkout $TRILINOS_BRANCH
git reset --hard origin/$TRILINOS_BRANCH
git pull
cd ..

python kokkos/config/snapshot.py ${KOKKOS_PATH} ${TRILINOS_UPDATED_PATH}/packages

cd ${TRILINOS_UPDATED_PATH}
echo ""
echo ""
echo "Trilinos State:"
git log --pretty=oneline --since=7.days
SHA=`git log --pretty=oneline --since=7.days | head -n 2 | tail -n 1 | awk '{print $1}'`
cd ..

cd ${TRILINOS_PRISTINE_PATH}
git status
git log --pretty=oneline --since=7.days
echo "Checkout $TRILINOS_BRANCH"
git checkout $TRILINOS_BRANCH
echo "Pull"
git pull
echo "Checkout SHA"
git checkout ${SHA}
cd ..

cd ${TRILINOS_PRISTINE_PATH}
echo ""
echo ""
echo "Trilinos Pristine State:"
git log --pretty=oneline --since=7.days
cd ..
