import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  menuOpen: false,

  active: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === this.model;
  }),

  actions: {
    selectFolder() {
      this.get('onSelect')(this.model);
    },

    editFolder() {
      this.get('onEdit')(this.model);
    },

    toggleOpen() {
      this.model.set('open', !this.model.get('open'));
      this.model.save();
    },

    openMenu() {
      this.set('menuOpen', true);

      var that = this;
      Ember.$(document).one('mouseup', function() {
        that.set('menuOpen', false);
      });
    },

    markFolderRead() {
    },

    markFolderUnread() {
    },

    deleteFolder() {
      if(confirm('Delete folder "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
