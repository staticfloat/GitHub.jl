# This file tests various GitHubType constructors. To test for proper Nullable
# handling, most fields have been removed from the JSON samples used below.
# Sample fields were selected in order to cover the full range of type behavior,
# e.g. if the GitHubType has a few Nullable{Dates.DateTime} fields, at least one
# of those fields should be present in the JSON sample.

function test_show(g::GitHub.GitHubType)
    tmpio = IOBuffer()
    show(tmpio, g)

    # basically trivial, but proves that things aren't completely broken
    @test repr(g) == String(take!(tmpio))

    tmpio = IOBuffer()
    show(IOContext(tmpio, :compact => true), g)

    @test "$(typeof(g))($(repr(name(g))))" == String(take!(tmpio))
end

@testset "Owner" begin
    owner_json = JSON.parse(
    """
    {
      "id": 1,
      "email": null,
      "html_url": "https://github.com/octocat",
      "login": "octocat",
      "updated_at": "2008-01-14T04:33:35Z",
      "hireable": false
    }
    """
    )

    owner_result = Owner(
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(String(owner_json["login"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{Int}(Int(owner_json["id"])),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(HTTP.URI(owner_json["html_url"])),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(owner_json["updated_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{Dates.DateTime}(),
        Nullable{Bool}(Bool(owner_json["hireable"])),
        Nullable{Bool}()
    )

    @test Owner(owner_json) == owner_result
    @test name(Owner(owner_json["login"])) == name(owner_result)
    @test setindex!(GitHub.github2json(owner_result), nothing, "email") == owner_json

    test_show(owner_result)
end

@testset "Repo" begin
    repo_json = JSON.parse(
    """
    {
      "id": 1296269,
      "owner": {
        "login": "octocat"
      },
      "parent": {
        "name": "test-parent"
      },
      "full_name": "octocat/Hello-World",
      "private": false,
      "url": "https://api.github.com/repos/octocat/Hello-World",
      "language": null,
      "pushed_at": "2011-01-26T19:06:43Z",
      "permissions": {
        "admin": false,
        "push": false,
        "pull": true
      }
    }
    """
    )

    repo_result = Repo(
        Nullable{String}(),
        Nullable{String}(String(repo_json["full_name"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{Owner}(Owner(repo_json["owner"])),
        Nullable{Repo}(Repo(repo_json["parent"])),
        Nullable{Repo}(),
        Nullable{Int}(Int(repo_json["id"])),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{HTTP.URI}(HTTP.URI(repo_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(repo_json["pushed_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{Dates.DateTime}(),
        Nullable{Bool}(),
        Nullable{Bool}(),
        Nullable{Bool}(),
        Nullable{Bool}(),
        Nullable{Bool}(Bool(repo_json["private"])),
        Nullable{Bool}(),
        Nullable{Dict}(repo_json["permissions"])
    )

    @test Repo(repo_json) == repo_result
    @test name(Repo(repo_json["full_name"])) == name(repo_result)
    @test setindex!(GitHub.github2json(repo_result), nothing, "language") == repo_json

    test_show(repo_result)
end

@testset "Commit" begin
    commit_json = JSON.parse(
    """
    {
      "url": "https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e",
      "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e",
      "html_url": null,
      "commit": {
        "message": "Fix all the bugs",
        "comment_count": 0
      },
      "author": {
        "login": "octocat"
      },
      "parents": [
        {
          "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e"
        },
        {
          "sha": "7ed9340c309dd91757664cee6d857d161c14e095"
        }
      ],
      "stats": {
        "total": 108
      },
      "files": [
        {
          "filename": "file1.txt"
        },
        {
          "filename": "file2.txt"
        }
      ]
    }
    """
    )

    commit_result = Commit(
        Nullable{String}(String(commit_json["sha"])),
        Nullable{String}(),
        Nullable{Owner}(Owner(commit_json["author"])),
        Nullable{Owner}(),
        Nullable{Commit}(Commit(commit_json["commit"])),
        Nullable{HTTP.URI}(HTTP.URI(commit_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{Vector{Commit}}(map(Commit, commit_json["parents"])),
        Nullable{Dict}(commit_json["stats"]),
        Nullable{Vector{Content}}(map(Content, commit_json["files"])),
        Nullable{Int}()
    )

    @test Commit(commit_json) == commit_result
    @test name(Commit(commit_json["sha"])) == name(commit_result)
    @test setindex!(GitHub.github2json(commit_result), nothing, "html_url") == commit_json

    test_show(commit_result)
end

@testset "Branch" begin
    branch_json = JSON.parse(
    """
    {
      "name": "master",
      "sha": null,
      "protection": {
        "enabled": false,
        "required_status_checks": {
          "enforcement_level": "off",
          "contexts": []
        }
      },
      "commit": {
        "sha": "7fd1a60b01f91b314f59955a4e4d4e80d8edf11d"
      },
      "user": {
        "login": "octocat"
      },
      "repo": {
        "full_name": "octocat/Hello-World"
      }
    }
    """
    )

    branch_result = Branch(
        Nullable{String}(String(branch_json["name"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{Commit}(Commit(branch_json["commit"])),
        Nullable{Owner}(Owner(branch_json["user"])),
        Nullable{Repo}(Repo(branch_json["repo"])),
        Nullable{Dict}(),
        Nullable{Dict}(branch_json["protection"])
    )

    @test Branch(branch_json) == branch_result
    @test name(Branch(branch_json["name"])) == name(branch_result)
    @test setindex!(GitHub.github2json(branch_result), nothing, "sha") == branch_json

    test_show(branch_result)
end

@testset "Comment" begin
    comment_json = JSON.parse(
    """
    {
      "url": "https://api.github.com/repos/octocat/Hello-World/comments/1",
      "id": 1,
      "position": null,
      "body": "Great stuff",
      "user": {
        "login": "octocat"
      },
      "created_at": "2011-04-14T16:00:49Z"
    }
    """
    )

    comment_result = Comment(
        Nullable{String}(String(comment_json["body"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{Int}(Int(comment_json["id"])),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(comment_json["created_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{HTTP.URI}(HTTP.URI(comment_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{Owner}(Owner(comment_json["user"]))
    )

    @test Comment(comment_json) == comment_result
    @test name(Comment(comment_json["id"])) == name(comment_result)
    @test setindex!(GitHub.github2json(comment_result), nothing, "position") == comment_json

    test_show(comment_result)
end

@testset "Content" begin
    content_json = JSON.parse(
    """
    {
      "type": "file",
      "path": "lib/octokit.rb",
      "size": 625,
      "encoding": null,
      "url": "https://api.github.com/repos/octokit/octokit.rb/contents/lib/octokit.rb"
    }
    """
    )

    content_result = Content(
        Nullable{String}(String(content_json["type"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(String(content_json["path"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{HTTP.URI}(HTTP.URI(content_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{Int}(content_json["size"])
    )

    @test Content(content_json) == content_result
    @test name(Content(content_json["path"])) == name(content_result)
    @test setindex!(GitHub.github2json(content_result), nothing, "encoding") == content_json

    test_show(content_result)
end


@testset "Status" begin
    status_json = JSON.parse(
    """
    {
      "created_at": "2012-07-20T01:19:13Z",
      "description": "Build has completed successfully",
      "id": 1,
      "context": null,
      "url": "https://api.github.com/repos/octocat/Hello-World/statuses/1",
      "creator": {
        "login": "octocat"
      },
      "statuses": [
        {
          "id": 366962428
        }
      ],
      "repository": {
        "full_name": "JuliaWeb/GitHub.jl"
      }
    }
    """
    )

    status_result = Status(
        Nullable{Int}(Int(status_json["id"])),
        Nullable{Int}(),
        Nullable{String}(),
        Nullable{String}(String(status_json["description"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{HTTP.URI}(HTTP.URI(status_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(status_json["created_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{Owner}(Owner(status_json["creator"])),
        Nullable{Repo}(Repo(status_json["repository"])),
        Nullable{Vector{Status}}(map(Status, status_json["statuses"]))
    )

    @test Status(status_json) == status_result
    @test name(Status(status_json["id"])) == name(status_result)
    @test setindex!(GitHub.github2json(status_result), nothing, "context") == status_json

    test_show(status_result)
end

@testset "PullRequest" begin
    pr_json = JSON.parse(
    """
    {
      "url": "https://api.github.com/repos/octocat/Hello-World/pulls/1347",
      "number": 1347,
      "body": "Please pull these awesome changes",
      "assignee": {
        "login": "octocat"
      },
      "milestone": {
        "id": 1002604,
        "number": 1,
        "state": "open",
        "title": "v1.0"
      },
      "locked": false,
      "created_at": "2011-01-26T19:01:12Z",
      "head": {
        "ref": "new-topic"
      }
    }
    """
    )

    pr_result = PullRequest(
        Nullable{Branch}(),
        Nullable{Branch}(Branch(pr_json["head"])),
        Nullable{Int}(Int(pr_json["number"])),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{String}(String(pr_json["body"])),
        Nullable{String}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(pr_json["created_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{Dates.DateTime}(),
        Nullable{Dates.DateTime}(),
        Nullable{HTTP.URI}(HTTP.URI(pr_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{Owner}(Owner(pr_json["assignee"])),
        Nullable{Owner}(),
        Nullable{Owner}(),
        Nullable{Dict}(pr_json["milestone"]),
        Nullable{Dict}(),
        Nullable{Bool}(),
        Nullable{Bool}(),
        Nullable{Bool}(pr_json["locked"])
    )

    @test PullRequest(pr_json) == pr_result
    @test name(PullRequest(pr_json["number"])) == name(pr_result)
    @test GitHub.github2json(pr_result) == pr_json

    test_show(pr_result)
end

@testset "Issue" begin
    issue_json = JSON.parse(
    """
    {
      "url": "https://api.github.com/repos/octocat/Hello-World/issues/1347",
      "number": 1347,
      "title": "Found a bug",
      "user": {
        "login": "octocat"
      },
      "labels": [
        {
          "url": "https://api.github.com/repos/octocat/Hello-World/labels/bug",
          "name": "bug",
          "color": "f29513"
        }
      ],
      "pull_request": {
        "url": "https://api.github.com/repos/octocat/Hello-World/pulls/1347",
        "html_url": "https://github.com/octocat/Hello-World/pull/1347"
      },
      "locked": false,
      "closed_at": null,
      "created_at": "2011-04-22T13:33:48Z"
    }
    """
    )

    issue_result = Issue(
        Nullable{Int}(),
        Nullable{Int}(Int(issue_json["number"])),
        Nullable{Int}(),
        Nullable{String}(String(issue_json["title"])),
        Nullable{String}(),
        Nullable{String}(),
        Nullable{Owner}(Owner(issue_json["user"])),
        Nullable{Owner}(),
        Nullable{Owner}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop(issue_json["created_at"]))),
        Nullable{Dates.DateTime}(),
        Nullable{Dates.DateTime}(),
        Nullable{Vector{Dict}}(Vector{Dict}(issue_json["labels"])),
        Nullable{Dict}(),
        Nullable{PullRequest}(PullRequest(issue_json["pull_request"])),
        Nullable{HTTP.URI}(HTTP.URI(issue_json["url"])),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{HTTP.URI}(),
        Nullable{Bool}(Bool(issue_json["locked"]))
    )

    @test Issue(issue_json) == issue_result
    @test name(Issue(issue_json["number"])) == name(issue_result)
    @test setindex!(GitHub.github2json(issue_result), nothing, "closed_at") == issue_json

    test_show(issue_result)
end

@testset "Team" begin
    team_json = JSON.parse("""
      {
        "id": 1,
        "url": "https://api.github.com/teams/1",
        "name": "Justice League",
        "slug": "justice-league",
        "description": "A great team.",
        "privacy": "closed",
        "permission": "admin",
        "members_url": "https://api.github.com/teams/1/members{/member}",
        "repositories_url": "https://api.github.com/teams/1/repos"
      }
    """)

    team_result = Team(
        Nullable{String}(team_json["name"]),
        Nullable{String}(team_json["description"]),
        Nullable{String}(team_json["privacy"]),
        Nullable{String}(team_json["permission"]),
        Nullable{String}(team_json["slug"]),
        Nullable{Int}(Int(team_json["id"])))

    @test name(team_result) == Int(team_json["id"])
    test_show(team_result)
end

@testset "Webhook" begin
    hook_json = JSON.parse("""
      {
        "id": 12625455,
        "url": "https://api.github.com/repos/user/Example.jl/hooks/12625455",
        "test_url": "https://api.github.com/repos/user/Example.jl/hooks/12625455/test",
        "ping_url": "https://api.github.com/repos/user/Example.jl/hooks/12625455/pings",
        "name": "web",
        "events": ["push", "pull_request"],
        "active": true,
        "updated_at": "2017-03-14T14:03:16Z",
        "created_at": "2017-03-14T14:03:16Z"
      }
    """)

    hook_result = Webhook(
        Nullable{Int}(hook_json["id"]),
        Nullable{HTTP.URI}(HTTP.URI(hook_json["url"])),
        Nullable{HTTP.URI}(HTTP.URI(hook_json["test_url"])),
        Nullable{HTTP.URI}(HTTP.URI(hook_json["ping_url"])),
        Nullable{String}(hook_json["name"]),
        Nullable{Array{String}}(map(String, hook_json["events"])),
        Nullable{Bool}(hook_json["active"]),
        Nullable{Dict{String, String}}(),
        Nullable{Dates.DateTime}(Dates.DateTime(chop("2017-03-14T14:03:16Z"))),
        Nullable{Dates.DateTime}(Dates.DateTime(chop("2017-03-14T14:03:16Z"))))

    @test Webhook(hook_json) == hook_result
    @test name(Webhook(hook_json["id"])) == name(hook_result)
    @test setindex!(GitHub.github2json(hook_result), "web", "name") == hook_json

    test_show(hook_result)
end

@testset "Gist" begin
    gist_json = JSON.parse("""
      {
        "url": "https://api.github.com/gists/aa5a315d61ae9438b18d",
        "forks_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/forks",
        "commits_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/commits",
        "id": "aa5a315d61ae9438b18d",
        "description": "description of gist",
        "public": true,
        "owner": {
          "login": "octocat",
          "id": 1,
          "gravatar_id": "",
          "url": "https://api.github.com/users/octocat",
          "type": "User",
          "site_admin": false
        },
        "user": null,
        "files": {
          "ring.erl": {
            "size": 932,
            "raw_url": "https://gist.githubusercontent.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl",
            "type": "text/plain",
            "language": "Erlang",
            "truncated": false,
            "content": "contents of gist"
          }
        },
        "truncated": false,
        "comments": 0,
        "comments_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/comments/",
        "html_url": "https://gist.github.com/aa5a315d61ae9438b18d",
        "git_pull_url": "https://gist.github.com/aa5a315d61ae9438b18d.git",
        "git_push_url": "https://gist.github.com/aa5a315d61ae9438b18d.git",
        "created_at": "2010-04-14T02:15:15Z",
        "updated_at": "2011-06-20T11:34:15Z",
        "forks": [
          {
            "user": {
              "login": "octocat",
              "id": 1,
              "gravatar_id": "",
              "url": "https://api.github.com/users/octocat",
              "site_admin": false
            },
            "url": "https://api.github.com/gists/dee9c42e4998ce2ea439",
            "id": "dee9c42e4998ce2ea439",
            "created_at": "2011-04-14T16:00:49Z",
            "updated_at": "2011-04-14T16:00:49Z"
          }
        ],
        "history": [
          {
            "url": "https://api.github.com/gists/aa5a315d61ae9438b18d/57a7f021a713b1c5a6a199b54cc514735d2d462f",
            "version": "57a7f021a713b1c5a6a199b54cc514735d2d462f",
            "user": {
              "login": "octocat",
              "id": 1,
              "avatar_url": "https://github.com/images/error/octocat_happy.gif",
              "gravatar_id": "",
              "url": "https://api.github.com/users/octocat",
              "html_url": "https://github.com/octocat",
              "followers_url": "https://api.github.com/users/octocat/followers",
              "following_url": "https://api.github.com/users/octocat/following{/other_user}",
              "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
              "organizations_url": "https://api.github.com/users/octocat/orgs",
              "repos_url": "https://api.github.com/users/octocat/repos",
              "events_url": "https://api.github.com/users/octocat/events{/privacy}",
              "received_events_url": "https://api.github.com/users/octocat/received_events",
              "type": "User",
              "site_admin": false
            },
            "change_status": {
              "deletions": 0,
              "additions": 180,
              "total": 180
            },
            "committed_at": "2010-04-14T02:15:15Z"
          }
        ]
      }
      """
    )

    gist_result = Gist(
      Nullable{HTTP.URI}(HTTP.URI(gist_json["url"])),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["forks_url"])),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["commits_url"])),
      Nullable{String}(gist_json["id"]),
      Nullable{String}(gist_json["description"]),
      Nullable{Bool}(gist_json["public"]),
      Nullable{Owner}(Owner(gist_json["owner"])),
      Nullable{Owner}(),
      Nullable{Bool}(gist_json["truncated"]),
      Nullable{Int}(gist_json["comments"]),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["comments_url"])),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["html_url"])),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["git_pull_url"])),
      Nullable{HTTP.URI}(HTTP.URI(gist_json["git_push_url"])),
      Nullable{Dates.DateTime}(Dates.DateTime(chop(gist_json["created_at"]))),
      Nullable{Dates.DateTime}(Dates.DateTime(chop(gist_json["updated_at"]))),
      Nullable{Vector{Gist}}(map(Gist, gist_json["forks"])),
      Nullable{Dict}(gist_json["files"]),
      Nullable{Vector{Dict}}(gist_json["history"]),
    )

    @test Gist(gist_json) == gist_result
    @test name(Gist(gist_json["id"])) == name(gist_result)
    @test setindex!(GitHub.github2json(gist_result), nothing, "user") == gist_json

    test_show(gist_result)
end

@testset "Installation" begin
    # This is the format of an installation in the "installation event"
    installation_json = JSON.parse("""
      {
        "id": 42926,
        "account": {
          "login": "Keno",
          "id": 1291671,
          "avatar_url": "https://avatars1.githubusercontent.com/u/1291671?v=4",
          "gravatar_id": "",
          "url": "https://api.github.com/users/Keno",
          "html_url": "https://github.com/Keno",
          "followers_url": "https://api.github.com/users/Keno/followers",
          "following_url": "https://api.github.com/users/Keno/following{/other_user}",
          "gists_url": "https://api.github.com/users/Keno/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/Keno/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/Keno/subscriptions",
          "organizations_url": "https://api.github.com/users/Keno/orgs",
          "repos_url": "https://api.github.com/users/Keno/repos",
          "events_url": "https://api.github.com/users/Keno/events{/privacy}",
          "received_events_url": "https://api.github.com/users/Keno/received_events",
          "type": "User",
          "site_admin": false
        },
        "repository_selection": "selected",
        "access_tokens_url": "https://api.github.com/installations/42926/access_tokens",
        "repositories_url": "https://api.github.com/installation/repositories",
        "html_url": "https://github.com/settings/installations/42926",
        "app_id": 4123,
        "target_id": 1291671,
        "target_type": "User",
        "permissions": {
          "contents": "read",
          "metadata": "read",
          "pull_requests": "read"
        },
        "events": [
          "commit_comment",
          "pull_request",
          "push",
          "release"
        ],
        "created_at": 1501449845,
        "updated_at": 1501449845,
        "single_file_name": null
      }
    """)

    installation_result = Installation(installation_json)

    @test name(installation_result) == Int(installation_json["id"])
end

@testset "Apps" begin
    app_json = JSON.parse("""
      {
        "id": 1,
        "owner": {
          "login": "github",
          "id": 1,
          "url": "https://api.github.com/orgs/github",
          "repos_url": "https://api.github.com/orgs/github/repos",
          "events_url": "https://api.github.com/orgs/github/events",
          "hooks_url": "https://api.github.com/orgs/github/hooks",
          "issues_url": "https://api.github.com/orgs/github/issues",
          "members_url": "https://api.github.com/orgs/github/members{/member}",
          "public_members_url": "https://api.github.com/orgs/github/public_members{/member}",
          "avatar_url": "https://github.com/images/error/octocat_happy.gif",
          "description": "A great organization"
        },
        "name": "Super CI",
        "description": "",
        "external_url": "https://example.com",
        "html_url": "https://github.com/apps/super-ci",
        "created_at": "2017-07-08T16:18:44",
        "updated_at": "2017-07-08T16:18:44"
      }
    """)

    app_result = App(app_json)
    @test name(app_result) == Int(app_json["id"])
end

@testset "Review" begin
    review_json = JSON.parse("""
      {
        "id": 80,
        "user": {
          "login": "octocat",
          "id": 1,
          "avatar_url": "https://github.com/images/error/octocat_happy.gif",
          "gravatar_id": "",
          "url": "https://api.github.com/users/octocat",
          "html_url": "https://github.com/octocat",
          "followers_url": "https://api.github.com/users/octocat/followers",
          "following_url": "https://api.github.com/users/octocat/following{/other_user}",
          "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
          "organizations_url": "https://api.github.com/users/octocat/orgs",
          "repos_url": "https://api.github.com/users/octocat/repos",
          "events_url": "https://api.github.com/users/octocat/events{/privacy}",
          "received_events_url": "https://api.github.com/users/octocat/received_events",
          "type": "User",
          "site_admin": false
        },
        "body": "Here is the body for the review.",
        "commit_id": "ecdd80bb57125d7ba9641ffaa4d7d2c19d3f3091",
        "state": "APPROVED",
        "html_url": "https://github.com/octocat/Hello-World/pull/12#pullrequestreview-80",
        "pull_request_url": "https://api.github.com/repos/octocat/Hello-World/pulls/12",
        "_links": {
          "html": {
            "href": "https://github.com/octocat/Hello-World/pull/12#pullrequestreview-80"
          },
          "pull_request": {
            "href": "https://api.github.com/repos/octocat/Hello-World/pulls/12"
          }
        }
      }
    """)

    review_result = App(review_json)
    @test name(review_result) == Int(review_json["id"])
end

@testset "Blob" begin
    blob_json = JSON.parse("""
    {
      "content": "Q29udGVudCBvZiB0aGUgYmxvYg==\\n",
      "encoding": "base64",
      "url": "https://api.github.com/repos/octocat/example/git/blobs/3a0f86fb8db8eea7ccbb9a95f325ddbedfb25e15",
      "sha": "3a0f86fb8db8eea7ccbb9a95f325ddbedfb25e15",
      "size": 19
    }
    """)

    blob_result = Blob(blob_json)
    @test name(blob_result) == blob_json["sha"]
end

@testset "Git Commit" begin
    commit_json = JSON.parse("""
    {
      "sha": "7638417db6d59f3c431d3e1f261cc637155684cd",
      "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/7638417db6d59f3c431d3e1f261cc637155684cd",
      "author": {
        "date": "2014-11-07T22:01:45Z",
        "name": "Scott Chacon",
        "email": "schacon@gmail.com"
      },
      "committer": {
        "date": "2014-11-07T22:01:45Z",
        "name": "Scott Chacon",
        "email": "schacon@gmail.com"
      },
      "message": "added readme, because im a good github citizen",
      "tree": {
        "url": "https://api.github.com/repos/octocat/Hello-World/git/trees/691272480426f78a0138979dd3ce63b77f706feb",
        "sha": "691272480426f78a0138979dd3ce63b77f706feb"
      },
      "parents": [
        {
          "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/1acc419d4d6a9ce985db7be48c6349a0475975b5",
          "sha": "1acc419d4d6a9ce985db7be48c6349a0475975b5"
        }
      ],
      "verification": {
        "verified": false,
        "reason": "unsigned",
        "signature": null,
        "payload": null
      }
    }
    """)
    commit_result = GitCommit(commit_json)
    @test name(commit_result) == commit_json["sha"]
end

@testset "Reference" begin
    reference_json = JSON.parse("""
    {
      "ref": "refs/heads/featureA",
      "url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA",
      "object": {
        "type": "commit",
        "sha": "aa218f56b14c9653891f9e74264a383fa43fefbd",
        "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"
      }
    }
    """)

    reference_result = Reference(reference_json)
    @test name(reference_result) == "heads/featureA"
end

@testset "Tag" begin
    tag_json = JSON.parse("""
    {
      "tag": "v0.0.1",
      "sha": "940bd336248efae0f9ee5bc7b2d5c985887b16ac",
      "url": "https://api.github.com/repos/octocat/Hello-World/git/tags/940bd336248efae0f9ee5bc7b2d5c985887b16ac",
      "message": "initial version",
      "tagger": {
        "name": "Scott Chacon",
        "email": "schacon@gmail.com",
        "date": "2014-11-07T22:01:45Z"
      },
      "object": {
        "type": "commit",
        "sha": "c3d0be41ecbe669545ee3e94d31ed9a4bc91ee3c",
        "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/c3d0be41ecbe669545ee3e94d31ed9a4bc91ee3c"
      },
      "verification": {
        "verified": false,
        "reason": "unsigned",
        "signature": null,
        "payload": null
      }
    }
    """)

    tag_result = Tag(tag_json)
    @test name(tag_result) == tag_json["sha"]
end

@testset "Tree" begin
    tree_json = JSON.parse("""
    {
      "sha": "9fb037999f264ba9a7fc6274d15fa3ae2ab98312",
      "url": "https://api.github.com/repos/octocat/Hello-World/trees/9fb037999f264ba9a7fc6274d15fa3ae2ab98312",
      "tree": [
        {
          "path": "file.rb",
          "mode": "100644",
          "type": "blob",
          "size": 30,
          "sha": "44b4fc6d56897b048c772eb4087f854f46256132",
          "url": "https://api.github.com/repos/octocat/Hello-World/git/blobs/44b4fc6d56897b048c772eb4087f854f46256132"
        },
        {
          "path": "subdir",
          "mode": "040000",
          "type": "tree",
          "sha": "f484d249c660418515fb01c2b9662073663c242e",
          "url": "https://api.github.com/repos/octocat/Hello-World/git/blobs/f484d249c660418515fb01c2b9662073663c242e"
        },
        {
          "path": "exec_file",
          "mode": "100755",
          "type": "blob",
          "size": 75,
          "sha": "45b983be36b73c0788dc9cbcb76cbb80fc7bb057",
          "url": "https://api.github.com/repos/octocat/Hello-World/git/blobs/45b983be36b73c0788dc9cbcb76cbb80fc7bb057"
        }
      ],
      "truncated": false
    }
    """)

    tree_result = Tree(tree_json)
    @test name(tree_result) == tree_json["sha"]
end
