import Ember from 'ember';

export default Ember.Mixin.create({
  filters: Ember.inject.service('item-filters'),

  _allLoaded: false,

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  beforeModel() {
    this.store.unloadAll('item');
    this.set('_allLoaded', false);
  },

  loadMore() {
    var promise = null;

    if(!this.get('_allLoaded')) {
      promise = this.store.query('item', this.get('filters').generateQueryData()).then(Ember.run.bind(this, function(newItems) {
        if(newItems.content.length === 0) {
          this.set('_allLoaded', true);
        }
      }));
      this.incrementProperty('filters.page');
    }

    return promise;
  },
});
