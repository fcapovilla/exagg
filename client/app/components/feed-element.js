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

    openMenu() {
      var that = this;
      that.set('menuOpen', true);

      $(document).one('mouseup', function() {
        that.set('menuOpen', false);
      });
    },

    markFeedRead() {
    },

    markFeedUnread() {
    },

    editFeed() {
      this.get('boundController').transitionToRoute('feed.edit', this.model);
    },

    deleteFeed() {
      if(confirm('Delete feed "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
