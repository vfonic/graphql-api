#!/bin/bash

ver=$1

> lib/graphql/api/version.rb
printf "module GraphQL\n  module Api\n    VERSION = '${1}'\n  end\nend\n" >> lib/graphql/api/version.rb
git commit -am "release version ${1}"

gem build graphql-api.gemspec
gem push graphql-api-${1}.gem
rm graphql-api-${1}.gem

git tag -a v${1} -m "release version ${1}"
git push origin --all --follow-tags
