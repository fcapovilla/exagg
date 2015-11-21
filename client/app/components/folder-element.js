import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  menuOpen: false,

  actions: {
    selectFolder() {
      this.get('boundController').transitionToRoute('folder', this.model);
    },

    toggleOpen() {
      this.model.set('open', !this.model.get('open'));
      this.model.save();
    },

    toggleMenu() {
      this.set('menuOpen', !this.get('menuOpen'));
    },

    markFolderRead() {
    },

    markFolderUnread() {
    },

    editFolder() {
    },

    deleteFolder() {
      if(confirm('Delete folder "' + this.model.get("title") + '"?')) {
        this.model.destroyRecord();
      }
    }
  }
});
