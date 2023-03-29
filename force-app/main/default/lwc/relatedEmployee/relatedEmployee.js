import {LightningElement, api, track} from 'lwc';
import {subscribe, unsubscribe, onError, setDebugFlag} from 'lightning/empApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
// import {refreshApex} from '@salesforce/apex';
// import {getRecords} from "lightning/uiRecordApi";

import getRelatedRecords from '@salesforce/apex/RelatedEmployeeController.getRelatedRecords';
import hireEmployee from '@salesforce/apex/RelatedEmployeeController.hireEmployee';
import dismissEmployee from '@salesforce/apex/RelatedEmployeeController.dismissEmployee';


const columns = [
    {label: 'Employee Name', fieldName: 'Employee_Name__c', type: 'string'},
    {label: 'Position', fieldName: 'Position__c', type: 'string'}
]
export default class RelatedEmployee extends LightningElement {

    @track data;
    @api recordId;
    columns = columns;
    showModal = false;
    subscription=null;
    rowsIdWithSelectedEmployee;

    // result;


    async connectedCallback() {
        this.handleWindowUpdateCall();
        console.log(this.data);
        this.subscribeToHiredEmployeeEvents();
    }

  async disconnectedCallback() {
      await  unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from Employee Hired events: ', JSON.stringify(response));
        });
        this.subscription = null;
    }
    subscribeToHiredEmployeeEvents() {

        const channel = '/event/Hired_Employee__e';
        this.subscription = subscribe(channel, -1, (event) => {
            console.log('Employee Hired event received: ', JSON.stringify(event));
            if (event.data.payload.Movie_Id__c===this.recordId){
               this.handleWindowUpdateCall();
            }
            else{
                console.error('Employee Hired event received different Movie_Id');
            }
        });
    }
    handleWindowUpdateCall() {
        console.error('handleWindowUpdateCall');
        getRelatedRecords({recordId: this.recordId})
            .then(result => {
                this.data = result.map(record => {
                    const employee = record.movieEmployee.Employee__r;
                    return {
                        Id:record.movieEmployee.Id,
                        Employee_Name__c: employee.Employee_Name__c,
                        Position__c: record.movieEmployee.Position__c
                    };
                });
            })
            .catch(error => {
                console.error(error);
                this.data = undefined;
            });
    }

    // @wire(getRelatedRecords, {recordId: '$recordId'})
    // getRecords(result) {
    //     console.log('I am inside get records');
    //     this.result=result;
    //     if (result.data) {
    //         this.data= result.data.map(record => {
    //             const employee = record.Employee__r;
    //             return {
    //                 Employee_Name__c: employee.Employee_Name__c,
    //                 Position__c: record.Position__c
    //             };
    //         });
    //     } else if (result.error) {
    //         this.data = undefined;
    //     }
    //     console.log('data!!!!!!!!!!!!!!!!!!!!!!!' + this.data);
    // }

    addNewEmployeeClick() {
        this.changeShowModalStatus();
    }
   async dismissNewEmployeeClick(){
        if(this.rowsIdWithSelectedEmployee!== undefined){
            console.log('Called dismissNewEmployee');

         await dismissEmployee({employeeIdsList: this.rowsIdWithSelectedEmployee}).then(()=>{
             console.log('Success to dismissEmployee');
         }).catch(error => {
             console.error(error);
         })
        }
    }

    changeShowModalStatus() {
        this.showModal = !this.showModal;
        console.log('Modal show: ' + this.showModal);
    }

    handleCancelParent(event) {
        // console.log('Cancel inside Main');
        // console.log('Event: ' + event);
        if (event.detail === 'Cancel') {
            this.changeShowModalStatus();
        }
    }

    async handleSaveParent(event) {
        const employeeId = event.detail.employeeId;
        const position = event.detail.employeePosition;

        try {
            await hireEmployee({movieId: this.recordId, employeeId: employeeId, position: position});
            this.showSuccessMessage();
            console.error('Before update data');
            await this.handleWindowUpdateCall();
            //   await  refreshApex(this.result);
        } catch (error) {
            this.showErrorMessage(error.body.message);
        }
        this.changeShowModalStatus();
        // console.log('Data after: '+JSON.stringify(this.data).length);
    }

    showSuccessMessage() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The employee was hired.',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    showErrorMessage(error) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'An error has occurred:' + error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    selectedRows(event){
        const selectedRows = event.detail.selectedRows;
        this.rowsIdWithSelectedEmployee=[];
        // Display that fieldName of the selected rows
        selectedRows.map(row=>{
            this.rowsIdWithSelectedEmployee.push(row.Id);
        })
        console.error('ROWS WITH IDS OF EMPLOYEES');
        for(let i = 0; i < this.rowsIdWithSelectedEmployee.length; i++) {
            console.log(this.rowsIdWithSelectedEmployee[i]);
        }
        console.log('-----------------------------------');
    }
}