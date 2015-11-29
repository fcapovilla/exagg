import Ember from 'ember';

export default Ember.Controller.extend({
  selectedItem: null,

  actions: {
    selectItem(item) {
      this.set('selectedItem', item);

      item.set('read', true);
      if(item.get('hasDirtyAttributes')) {
        item.save();
      }
    },

    nextItem() {
      var selected = this.get('selectedItem');
      var itemList = this.model.toArray();
      var item = itemList[itemList.indexOf(selected)+1];
      if(item) {
        this.send('selectItem', item);
      }
    },

    previousItem() {
      var selected = this.get('selectedItem');
      var itemList = this.model.toArray();
      var item = itemList[itemList.indexOf(selected)-1];
      if(item) {
        this.send('selectItem', item);
      }
    }
  }
});
