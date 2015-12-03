import Ember from 'ember';
import InfinityRoute from 'ember-infinity/mixins/route';

export default Ember.Route.extend(InfinityRoute, {
  perPageParam: "page_size",

  model() {
    return this.infinityModel('item', {perPage: 20, startingPage: 1, filter: {favorite: true}});
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
