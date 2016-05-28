import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  _allLoaded: false,

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  model() {
    this.store.unloadAll('item');
    this.set('_allLoaded', false);

    return this.store.peekAll('item');
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.get('filters').selectModel('favorites');
  },

  renderTemplate(controller, model) {
    this.render('item-list', {
      model: model
    });
  },

  actions: {
    loadMore() {
      if(!this.get('_allLoaded')) {
        this.store.query('item', this.get('filters').generateQueryData()).then(Ember.run.bind(this, function(newItems) {
          if(newItems.content.length === 0) {
            this.set('_allLoaded', true);
          }
        }));
        this.incrementProperty('filters.page');
      }
    }
  }
});
