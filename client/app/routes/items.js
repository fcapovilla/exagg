import Ember from 'ember';
import InfinityRoute from 'ember-infinity/mixins/route';

export default Ember.Route.extend(InfinityRoute, {
  perPageParam: "page_size",

  model() {
    return this.infinityModel('item', {perPage: 20, startingPage: 1});
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('index').set('selectedElement', 'items');
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      model: model
    });
  }
});
