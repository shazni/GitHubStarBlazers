import ballerinax/github;
import ballerina/http;

configurable string token = ?;

# A service representing a network-accessible API
# bound to port `9090`.

type RepositoryStar record {
    string repositoryName;
    int? numStars;
};

service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + organizationName - the input string name
    # + return - string name with hello message or error
    # Example call - curl "http://localhost:9090/getTopRepos?organizationName=wso2&repoLimit=5"
    resource function get getTopRepos(string organizationName, int repoLimit) returns json|error {
        // Send a response back to the caller.

        github:Client githubEndpoint = check new ({auth: {token: token}});
        RepositoryStar[] repositoryStar = [];
        stream<github:Repository, error?> gitHubRepositories = check githubEndpoint->getRepositories(owner = organizationName, isOrganization = true);

        check from record {} gitHubRepository in gitHubRepositories
            do {
                RepositoryStar repository = {
                    repositoryName: gitHubRepository.name,
                    numStars: gitHubRepository.stargazerCount
                };

                repositoryStar.push(repository);
            };

        string[] topRepositories =  from var repo in repositoryStar
                    order by repo.numStars descending limit repoLimit
                    select repo.repositoryName;

        return topRepositories.toJson();
    }
}
