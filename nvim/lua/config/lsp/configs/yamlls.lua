return {
    yaml = {
        validate = true,
        schemaStore = {
            enable = false,
            url = "",
        },
        schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/**/*.ya?ml",
            ["https://json.schemastore.org/cloudbuild.json"] = "cloudbuild.ya?ml",
            ["https://json.schemastore.org/kustomization.json"] = "kustomization.ya?ml",
        },
    },
    redhat = {
        telemetry = {
            enabled = false,
        },
    },
}
