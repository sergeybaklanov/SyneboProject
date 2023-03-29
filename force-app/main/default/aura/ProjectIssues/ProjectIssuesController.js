({
    // Load expenses from Salesforce
    doInit: function(cmp, event, helper) {
        // Create the action
        let action = cmp.get("c.obtainIssues");
        action.setParams({
            projectId:cmp.get("v.recordId")
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                cmp.set("v.issuesList",response.getReturnValue())
            } else {
                console.error("Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})