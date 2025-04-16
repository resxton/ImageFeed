import ImageFeed

struct StubProfileService: ProfileServiceProtocol {
    let profile: Profile? = Profile(from: ProfileResult(username: "Test Name", firstName: "@test", lastName: "Bio"))
}
