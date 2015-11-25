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
    },

    selectModel(model) {
      this.transitionToRoute(model.get('constructor.modelName'), model);
    },

    editModel(model) {
      this.transitionToRoute(model.get('constructor.modelName') + '.edit', model);
    },

    addFeed() {
      this.transitionToRoute('feed.new');
    }
  }
});
