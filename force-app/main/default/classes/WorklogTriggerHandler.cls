public with sharing class WorklogTriggerHandler extends TriggerHandler{
    public override void beforeInsert(){
        specifyBillableHours(null, Trigger.new );
    }

    public override void beforeUpdate(){
        specifyBillableHours((Map<Id, Worklog__c>)Trigger.oldMap, Trigger.new );
    }

    public override void beforeDelete(){
    }

    public override void afterInsert(){
        calculateTotalActualAndBillableHours(null, Trigger.new );
    }

    public override void afterUpdate(){
        calculateTotalActualAndBillableHours((Map<Id, Worklog__c>)Trigger.oldMap, Trigger.new );
    }

    public override void afterDelete(){
        calculateTotalActualAndBillableHours((Map<Id, Worklog__c>)Trigger.oldMap, null);
    }

    public override void afterUndelete(){
        calculateTotalActualAndBillableHours(null, Trigger.new );
    }

    private static void specifyBillableHours(Map<Id, Worklog__c> oldWorklogsMap, List<Worklog__c> newWorklogsList){

        for (Worklog__c worklog_i : newWorklogsList){
            if (Trigger.isInsert){
                if (worklog_i.Billable_hours__c == null && 'Issue'.equals(worklog_i.Type__c)){
                    worklog_i.Billable_hours__c = worklog_i.Actual_hours__c;
                }
                if ('Internal'.equals(worklog_i.Type__c)){
                    worklog_i.Billable_hours__c = 0;
                }
            }

            if (Trigger.isUpdate){

                if (oldWorklogsMap.get(worklog_i.Id).Type__c != worklog_i.Type__c || 
                    oldWorklogsMap.get(worklog_i.Id).Billable_hours__c != worklog_i.Billable_hours__c){

                    if (worklog_i.Billable_hours__c == null && 'Issue'.equals(worklog_i.Type__c)){
                        worklog_i.Billable_hours__c = worklog_i.Actual_hours__c;
                    }
                    if ('Internal'.equals(worklog_i.Type__c)){
                        worklog_i.Billable_hours__c = 0;
                    }
                }
            }
        }
    }

    private static void calculateTotalActualAndBillableHours(Map<Id, Worklog__c> oldMap, List<Worklog__c> newList){


        Set<Id> issuesIdsToUpdateSet = new Set<Id>();
        List<Issue__c> issuesToUpdateList = new List<Issue__c>();

        // Define a list to process.
        List<Worklog__c> worklogsListToProcess = (!Trigger.isDelete) ? newList : oldMap.values();

        // Define Issues to update
        for (Worklog__c worklog_i : worklogsListToProcess){


            // Check trigger operation type and add to the set of issues id
            if (Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete){

                // We skip all objects that have no connection with Issues
                if (worklog_i.Issue__c == null){
                    continue;
                }
                issuesIdsToUpdateSet.add(worklog_i.Issue__c);
            }

            if (Trigger.isUpdate){

                if (worklog_i.Issue__c != oldMap.get(worklog_i.Id).Issue__c){

                    if (worklog_i.Issue__c != null){
                        issuesIdsToUpdateSet.add(worklog_i.Issue__c);
                    }
                    if (oldMap.get(worklog_i.Id).Issue__c != null){
                        issuesIdsToUpdateSet.add(oldMap.get(worklog_i.Id).Issue__c);
                    }
                }
                // We skip all objects that have no connection with Issues
                if (worklog_i.Issue__c == null){
                    continue;
                }

                if (worklog_i.Actual_Hours__c != oldMap.get(worklog_i.Id).Actual_Hours__c || worklog_i.Billable_Hours__c != oldMap.get(worklog_i.Id).Billable_Hours__c){
                    issuesIdsToUpdateSet.add(worklog_i.Issue__c);
                }
            }
        }

        if (issuesIdsToupdateSet.isEmpty()){
            return;
        }

        List<AggregateResult> agrResList = [SELECT SUM(Actual_Hours__c)actualHours, SUM(Billable_Hours__c)billableHours, Issue__c issueId
                                            FROM Worklog__c 
                                            WHERE Issue__c IN:issuesIdsToUpdateSet
                                            GROUP BY Issue__c];

        if (!agrResList.isEmpty()){
            for (AggregateResult result_i : agrResList){
                issuesToUpdateList.add(new Issue__c(Id = (Id) result_i.get('issueId'), Total_Billable_Hours__c = Integer.valueOf(result_i.get('billableHours')), Total_Actual_Hours__c = Integer.valueOf(result_i.get('actualHours'))));
            }
        }

        if (!issuesToUpdateList.isEmpty()){
            update issuesToUpdateList;
        }
    }

}