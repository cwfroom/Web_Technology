import { Component } from '@angular/core';
import {FormControl} from '@angular/forms';




@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app';
  myControl: FormControl = new FormControl();

    options = [
      'One',
      'Two',
      'Three'
     ];
}

function haha() {
  console.log('haha');
}
