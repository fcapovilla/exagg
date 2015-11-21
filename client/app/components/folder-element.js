import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  menuOpen: false,

  active: Ember.computed('boundController.selectedElement', function() {
    return this.get('boundController.selectedElement') === this.model;
  }),

  actions: {
    selectFolder() {
      this.get('boundController').transitionToRoute('folder', this.model);
    },

    toggleOpen() {
      this.model.set('open', !this.model.get('open'));
      this.model.save();
    },

    openMenu() {
      this.set('menuOpen', true);

      var that = this;
      $(document).one('mouseup', function() {
        that.set('menuOpen', false);
      });
    },

    markFolderRead() {
    },

    markFolderUnread() {
    },

    editFolder() {
      this.get('boundController').transitionToRoute('folder.edit', this.model);
    },

    deleteFolder() {
      if(confirm('Delete folder "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
