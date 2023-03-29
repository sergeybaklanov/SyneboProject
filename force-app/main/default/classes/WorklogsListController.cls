public with sharing class WorklogsListController{
    public Id recordId{ get; set; }

    public Integer rowNumber{ get; set; }

    public Integer totalBillableHours{ get; set; }

    public Integer totalActualHours{ get; set; }

    public List<Worklog__c> worklogsList{ get; set; }

    public Project__c project{ get; set; }

    public Datetime dateCreation{ get; set; }

    public void getDateCreation(){
        this.dateCreation= Datetime.now();
    }

    public WorklogsListController(){
        this.recordId = ApexPages.currentPage().getParameters().get('id');
        this.rowNumber = -1;
        this.totalBillableHours = 0;
        this.totalActualHours = 0;

        this.project = [SELECT Id, Name, CreatedDate, Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email
                        FROM Project__c
                        WHERE Id = :recordId];

        this.worklogsList = [SELECT Id, Description__c, Type__c, Sub_type__c, Actual_hours__c, Billable_hours__c
                             FROM Worklog__c
                             WHERE Project__c = :recordId];

        for (Worklog__C worklog_i : worklogsList){
            this.totalBillableHours += (Integer) worklog_i.Billable_hours__c;
            this.totalActualHours += (Integer) worklog_i.Actual_hours__c;
        }
        getDateCreation();
    }

}