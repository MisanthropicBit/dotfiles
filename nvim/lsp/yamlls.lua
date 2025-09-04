return {
    settings = {
        yaml = {
            validate = true,
            schemaStore = {
                enable = false,
                url = "",
            },
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/**/*.ya?ml",
                ["https://json.schemastore.org/cloudbuild.json"] = "/cloudbuild.ya?ml",
                ["https://json.schemastore.org/kustomization.json"] = "/**/kustomization.ya?ml",
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.6-standalone-strict/all.json"] =
                "/*.yaml",
            },
        },
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
    },
}
