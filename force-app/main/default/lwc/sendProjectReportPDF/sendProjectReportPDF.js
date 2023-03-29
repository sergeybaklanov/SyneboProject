import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import sendReport from '@salesforce/apex/SendPdfReportController.sendReport';
import prepEmail from '@salesforce/apex/SendPdfReportController.prePopulationEmail'

export default class SendPdfReport extends LightningElement {
    @api recordId;
    @track email;
    isSend = false;
    connectedCallback() {
        console.log('inside connected callback:');
        prepEmail({recordId: this.recordId})
            .then(result => {
                this.email = result;
                console.log(result);
                console.log('email:', this.email);
            })
            .catch(error => {
                console.error('Error after method' + error);
            });
    }

    async handleClick() {
        this.isSend = true;
        // console.log('Start messages from here');
        // console.log(emailInputForm.id);
        // console.log(emailInputForm.style.display );
        const emailInput = this.template.querySelector('lightning-input');
        if (emailInput.checkValidity()) {
            this.email = this.template.querySelector('lightning-input').value;
            try {
                await sendReport({recordId: this.recordId, email: this.email});
              this.showSuccessMessage();
            } catch (error) {
                this.showErrorMessage(error.body.message);
            }
        }
        this.isSend = false;
    }

    showSuccessMessage() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The email has been successfully send.',
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
}