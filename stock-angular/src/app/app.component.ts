import { Component } from '@angular/core';
import {FormControl} from '@angular/forms';




@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app';
  searchFromControl: FormControl = new FormControl();

    options = [
      'One',
      'Two',
      'Three'
     ];

  completeSymbol(symbolin: string): void {
      console.log(symbolin);
  }


}

console.log('123');

