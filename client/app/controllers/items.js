import Ember from 'ember';

export default Ember.Controller.extend({
  selectedItem: null,

  actions: {
    selectItem(item) {
      if(this.get('selectedItem') !== null && this.get('selectedItem') !== item) {
        this.get('selectedItem').set('open', false);
      }
      this.set('selectedItem', item);
    }
  }
});
