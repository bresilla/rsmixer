build:
    cargo build --release

do type:
    #!/usr/bin/env bash
    IFS='.' read -r -a version_parts <<< $(cat Cargo.toml | grep version | head -1 | cut -d"=" -f 2 | tr -d '"' | xargs)
    case {{ type }} in
        "major")
            ((version_parts[0]++))
            ;;
        "minor")
            ((version_parts[1]++))
            ;;
        "patch")
            ((version_parts[2]++))
            ;;
        esac
    new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
    echo $new_version
    sed -i "0,/version = / s/version = \"[0-9.]\+\"/version = \"$new_version\"/" Cargo.toml
    version=v$(cat Cargo.toml | grep version | head -1 | cut -d"=" -f 2 | tr -d '"' | xargs)
    git add -A && git commit -m "chore(release): prepare for $version"
    git tag -a $version -m "$version"
    git push --follow-tags --force --set-upstream origin master
    gh release create $version
