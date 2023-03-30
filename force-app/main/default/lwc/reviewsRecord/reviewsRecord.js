import { LightningElement, api } from 'lwc';
import pullReviews from '@salesforce/apex/ReviewsController.pullReviews';
import movieRecordId from '@salesforce/apex/ReviewsController.movieRecordId';

export default class ReviewsRecord extends LightningElement {
    @api recordId;

    @api invoke() {
        console.log("Hi, I'm an action.");
        movieRecordId=this.recordId;
        pullReviews({movieRecordId: this.recordId}).then().catch(err => console.log(err));
      }
}