mutable struct Gist <: GitHubType
    url::Nullable{HTTP.URI}
    forks_url::Nullable{HTTP.URI}
    commits_url::Nullable{HTTP.URI}
    id::Nullable{String}
    description::Nullable{String}
    public::Nullable{Bool}
    owner::Nullable{Owner}
    user::Nullable{Owner}
    truncated::Nullable{Bool}
    comments::Nullable{Int}
    comments_url::Nullable{HTTP.URI}
    html_url::Nullable{HTTP.URI}
    git_pull_url::Nullable{HTTP.URI}
    git_push_url::Nullable{HTTP.URI}
    created_at::Nullable{Dates.DateTime}
    updated_at::Nullable{Dates.DateTime}
    forks::Nullable{Vector{Gist}}
    files::Nullable{Dict}
    history::Nullable{Vector{Dict}}
end

Gist(data::Dict) = json2github(Gist, data)
Gist(id::AbstractString) = Gist(Dict("id" => id))

namefield(gist::Gist) = gist.id

###############
# API Methods #
###############

# creating #
#----------#

@api_default gist(api::GitHubAPI, gist_obj::Gist; options...) = gist(api::GitHubAPI, name(gist_obj); options...)

@api_default function gist(api::GitHubAPI, gist_obj, sha = ""; options...)
    !isempty(sha) && (sha = "/" * sha)
    result = gh_get_json(api, "/gists/$(name(gist_obj))$sha"; options...)
    g = Gist(result)
end

@api_default function gists(api::GitHubAPI, owner; options...)
    results, page_data = gh_get_paged_json(api, "/users/$(name(owner))/gists"; options...)
    map(Gist, results), page_data
end

@api_default function gists(api::GitHubAPI; options...)
    results, page_data = gh_get_paged_json(api, "/gists/public"; options...)
    return map(Gist, results), page_data
end

# modifying #
#-----------#

@api_default create_gist(api::GitHubAPI; options...) = Gist(gh_post_json(api, "/gists"; options...))
@api_default edit_gist(api::GitHubAPI, gist; options...) = Gist(gh_patch_json(api, "/gists/$(name(gist))"; options...))
@api_default delete_gist(api::GitHubAPI, gist; options...) = gh_delete(api, "/gists/$(name(gist))"; options...)

# stars #
#------#

@api_default star_gist(api::GitHubAPI, gist; options...) = gh_put(api, "/gists/$(name(gist))/star"; options...)
@api_default unstar_gist(api::GitHubAPI, gist; options...) = gh_delete(api, "/gists/$(name(gist))/star"; options...)

@api_default function starred_gists(api::GitHubAPI; options...)
    results, page_data = gh_get_paged_json(api, "/gists/starred"; options...)
    return map(Gist, results), page_data
end

# forks #
#-------#

@api_default create_gist_fork(api::GitHubAPI, gist::Gist; options...) = Gist(gh_post_json(api, "/gists/$(name(gist))/forks"; options...))

@api_default function gist_forks(api::GitHubAPI, gist; options...)
    results, page_data = gh_get_paged_json(api, "/gists/$(name(gist))/forks"; options...)
    return map(Gist, results), page_data
end
