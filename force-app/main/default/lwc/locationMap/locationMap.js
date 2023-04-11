import { LightningElement, track } from 'lwc';
import getNearestCinemas from '@salesforce/apex/LocationMapController.getNearestCinemas';

export default class LocationMap extends LightningElement {  
      @track mapCenter;
      @track markers = [];
      @track selectedMarkerValue='';

      latitude;
      longitude;

      async connectedCallback() {
        let mapRes = [];
        console.log('Markers before');
        this.markers.forEach(element => {
          console.log(element.title);
          console.log(element.location.Latitude);
          console.log(element.location.Longitude);
          console.log(element.description);
          console.log(element.value);
        });
        //console.log(this.mapCenter.Latitude);
        
        try {
          let resultNearestCinemas = await getNearestCinemas();
          console.error('Before start');
          console.error(resultNearestCinemas);

          if (resultNearestCinemas.length) {
            
            resultNearestCinemas.map(element => {
              console.log('Inside element ' + element); // added space after 'element'      
              mapRes.push({
                location: {
                  Latitude: element.Location__Latitude__s,
                  Longitude: element.Location__Longitude__s
                }, 
                title: element.Name,
                description: element.Name,
                value: element.Id
              });
             
            }); // added closing parenthesis for map() function

            
          }
           console.error('MARKERS:'+this.markers);
        } catch (error) {
          console.log('Inside error');
          console.error('Data retrieving failed: ' + error); // added colon after error message
        }  
       
        //--------------------------------------------//
        try {
          const position = await new Promise((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(resolve, reject);
          });
    
          // handle success
          console.log('latitude:', position.coords.latitude);
          console.log('longitude:', position.coords.longitude);
          let center;

          center = {location:{
            Latitude: position.coords.latitude,
            Longitude:  position.coords.longitude}
          };
           this.mapCenter = center;
          mapRes.push({
            location: {Latitude: position.coords.latitude,
              Longitude:  position.coords.longitude},
            title: 'You are here',
            description: 'Your current location',
          });

        
        } catch (error) {
          // handle error
          console.error(error);
        }

          console.log('Markers after');
          this.markers.forEach(element => {
            console.log(element.title);
            console.log(element.location.Latitude);
            console.log(element.location.Longitude);
            console.log(element.description);
            console.log(element.value);
          }); 
          
          this.markers=mapRes;
  }  
  // selectedMarkerValue = 'CP';

  handleMarkerSelect(event) {
    console.log(event.detail);
    this.selectedMarkerValue = event.target.selectedMarkerValue;
    console.log('Event'+event.target);
  }
clickButton(){
  console.log('Activated button');
  this.template.querySelector('c-cinema-nav-tab').navigateNext(this.selectedMarkerValue);
}
}