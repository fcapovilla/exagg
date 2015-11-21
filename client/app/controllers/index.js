import Ember from 'ember';

export default Ember.Controller.extend({
  favoritesSelected: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === 'favorites';
  }),

  itemsSelected: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === 'items';
  }),

  actions: {
    selectFavorites() {
      this.transitionToRoute('favorites');
    },

    selectItems() {
      this.transitionToRoute('items');
    }
  }
});
