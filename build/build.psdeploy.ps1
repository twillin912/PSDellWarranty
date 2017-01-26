Deploy Module {
    By PSGalleryModule {
        FromSource $ModuleOutDir
        To PSGallery
        Tagged PSGallery
        WithOptions @{
            ApiKey = $env:NugetApiKey
        }
    }
}

Deploy DeveloperBuild {
    By AppVeyorModule {
        FromSource $ModuleOutDir
        To AppVeyor
        Tagged AppVeyor
        WithOptions @{
            Version = $env:APPVEYOR_BUILD_VERSION
        }
    }
}