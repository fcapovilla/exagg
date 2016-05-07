import Ember from 'ember';
import InfinityRoute from 'ember-infinity/mixins/route';

export default Ember.Route.extend(InfinityRoute, {
  perPageParam: "page_size",
  _canLoadMore: true,
  filters: Ember.inject.service('item-filters'),

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  model() {
    return this.infinityModel('item', {perPage: 20, startingPage: 1, filter: {favorite: true}, sort: "-date,id"}, {"filter[read]": "filters.read"});
  },

  afterInfinityModel(items) {
    var loadedAny = items.get('length') > 0;
    this.set('_canLoadMore', loadedAny);
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('index').set('selectedElement', 'favorites');
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      model: model
    });
  }
});
