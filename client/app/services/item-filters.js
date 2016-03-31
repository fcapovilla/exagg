import Ember from 'ember';

export default Ember.Service.extend({
  showRead: true,

  read: Ember.computed('showRead', function() {
    if(this.get('showRead') === false) {
      return false;
    }
    else {
      return null;
    }
  }),

  toggleReadVisibility() {
    this.set('showRead', !this.get('showRead'));
  },
});
