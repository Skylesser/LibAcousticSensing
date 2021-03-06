
/*******************************************************************************
* This file was generated by UI Builder.
* This file will be auto-generated each and everytime you save your project.
* Do not hand edit this file.
********************************************************************************/
				
#ifndef UIB_VIEW_MAIN_VIEW_H_
#define UIB_VIEW_MAIN_VIEW_H_


#include "g_inc_uib.h"
#include "uib_views.h"

/**
* view context definitions
*/

typedef struct _uib_view_main_view_context {

	/* parent evas_object which was parameter of create function */
	Evas_Object *parent;
	/* root container UI Component of this view */
	Evas_Object *root_container;
	/* view class name */
	const char *view_name;
	/* indicator state of this view */
	int indicator_state;
	/* This is view type. 'true' is user view, otherwise a UI Builder's view. */
	bool is_user_view;
	/* control context to control this view */
	struct _uib_view_main_control_context *cc;

	/* UI Components in this view */
	Evas_Object *grid_main;
	Evas_Object *entry_server_ip;
	Evas_Object *label1;
	Evas_Object *label_server_ip;
	Evas_Object *label_server_port;
	Evas_Object *entry_server_port;
	Evas_Object *button_settings;
	Evas_Object *label_mode;
	Evas_Object *hoversel_mode;
	Elm_Object_Item *hoverselitem_remote_mode;
	Elm_Object_Item *hoverselitem_standalone;
	Evas_Object *button_reset;
	Evas_Object *button_connect;
	Evas_Object *hoversel_server_ip;
	Evas_Object *hoversel_server_port;
	Evas_Object *button_exit;
} uib_view_main_view_context;



/**
* @brief	Create a new view then return view context of that view.
* 			You can delete view using evas_object_del(vc->evas_object) like other EFL evas objects.
*/
uib_view_context *uib_view_view_main_create(Evas_Object *parent, void *create_callback_param);
uib_view_context *uib_view_view_main_destroy(Evas_Object *parent, void *create_callback_param);

void uib_view_main_config_HD_portrait();
#endif /* UIB_VIEW_MAIN_VIEW_H_ */
