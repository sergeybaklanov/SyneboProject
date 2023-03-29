/**
 * Created by User on 07.03.2023.
 */
import LightningModal from 'lightning/modal';
import getAllEmployee from '@salesforce/apex/RelatedEmployeeController.getAllEmployees';
import {wire, api} from "lwc";


export default class SelectEmployeeModal extends LightningModal {
    dataPickList = [];
    @api employeeId;
    @api employeePosition;

    @wire(getAllEmployee)
    getEmployees({error, data}) {
        if (data) {
            this.dataPickList = data.map(record => {
                return {
                    label: record.Employee_Name__c,
                    value: record.Id
                };
            });
        } else if (error) {
            return {undefined};
        }
    }
    positionInputHandler(event) {
        this.employeePosition = event.detail.value;
    }
    handleChange(event) {
        this.employeeId = event.detail.value;
    }
    handleSave() {
        console.log('Select inside Modal');
        console.log('Employee ID: '+this.employeeId);
        console.log('Employee position: '+this.employeePosition);
        const event =
            new CustomEvent('save', {
                detail: {
                    'employeeId': this.employeeId,
                    'employeePosition': this.employeePosition
                }
            });
        this.dispatchEvent(event);
    }
    handleCancel() {
        console.log('Cancel inside Modal');
        const event = new CustomEvent('cancel', {detail: 'Cancel'});
        this.dispatchEvent(event);
        // this.changeShowModalStatus();
    }
}