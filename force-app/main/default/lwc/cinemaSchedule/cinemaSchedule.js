import {LightningElement, api, track} from 'lwc';
import getCinemaMovies from '@salesforce/apex/CinemaScheduleController.getCinemaMovies';

const columns = [
    {label: 'Movie', fieldName: 'Movie__c', type: 'string'},
    {label: 'Studio', fieldName: 'Studio__c', type: 'string'},
    {label: 'Director', fieldName: 'Employee__c', type: 'string'}
]
export default class CinemaSchedule extends LightningElement {
    @api recordId;
    @track dataCinemaMovies;
    columns = columns;

    showTable = false;
    hasNoDataInfo= false;

    selectedDate;

   async handleDateChange(event) {
        console.log(event.detail.value);
        this.selectedDate = event.detail.value;
        console.log('selectedDate:'+this.selectedDate);
        
        if(this.selectedDate!=null){
          await  this.setTableData();
          console.log('dataCinemaMovies: '+JSON.stringify(this.dataCinemaMovies));
            if(this.dataCinemaMovies!=null&& this.dataCinemaMovies.length!=0){
            this.showTable=true;
            }
        } else{ 
            this.showTable=false; 
        this.dataCinemaMovies=null;
        }
    }

    async setTableData(){
        console.log(this.recordId+' '+ this.selectedDate);
        try{
             let resultAfterAwait=  await getCinemaMovies({cinemaRecordId:this.recordId,selectedDate:this.selectedDate});
    if(resultAfterAwait.length){
            this.dataCinemaMovies=resultAfterAwait.map(element=>
           {
               const employee = element.Employee__r;
               const movie = element.Movie__r;
               console.log('Employee: '+employee.Employee_Name__c + ' Studio: ' +movie.Studio__r.Name+' Movie: ' + element.Movie__r.Name);
          
              return{
                  Movie__c: element.Movie__r.Name,
                  Studio__c: movie.Studio__r.Name,
                  Employee__c:employee.Employee_Name__c
              };
           })
           console.log('Next will be DATA cinema Movies');
            console.error(JSON.stringify(this.dataCinemaMovies));
           }
     else{
        console.error('Result returned empty array');
     }
        }
            catch(error){
                console.error('Data retrieving failed'+error);
            }  
     }
      
        
    
}