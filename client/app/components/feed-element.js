import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: ['feed'],

  menuOpen : false,

  active: Ember.computed('boundController.selectedElement', function() {
    return this.get('boundController.selectedElement') === this.model;
  }),

  actions: {
    selectFeed() {
      this.get('boundController').transitionToRoute('feed', this.model);
    },

    toggleMenu() {
      this.set('menuOpen', !this.get('menuOpen'));
    },

    markFeedRead() {
    },

    markFeedUnread() {
    },

    editFeed() {
    },

    deleteFeed() {
      if(confirm('Delete feed "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
