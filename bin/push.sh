#!/bin/bash

ver=$1
gem build graphql-api.gemspec

> lib/graphql/api/version.rb
printf "module GraphQL\n  module Api\n    VERSION = '${1}'\n  end\nend\n" >> lib/graphql/api/version.rb


gem push graphql-api-${1}.gem
rm graphql-api-${1}.gem

git tag -a v${1} -m "release version ${1}"
git push origin --all --tags
