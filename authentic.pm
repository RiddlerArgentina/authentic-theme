#
# Authentic Theme (https://github.com/authentic-theme/authentic-theme)
# Copyright Ilia Rostovtsev <programming@rostovtsev.io>
# Licensed under MIT (https://github.com/authentic-theme/authentic-theme/blob/master/LICENSE)
#
use strict;

use File::Basename;

our ($get_user_level,                $xnav,                     %theme_config,
     %theme_text,                    %config,                   %gconfig,
     %tconfig,                       %text,                     $basic_virtualmin_domain,
     $basic_virtualmin_menu,         $cb,                       $tb,
     $title,                         $cloudmin_no_create_links, $cloudmin_no_edit_buttons,
     $cloudmin_no_global_links,      $current_theme,            $done_theme_post_save_server,
     $mailbox_no_addressbook_button, $mailbox_no_folder_button, $module_index_link,
     $module_index_name,             $nocreate_virtualmin_menu, $nosingledomain_virtualmin_mode,
     $page_capture,                  $remote_user,              $root_directory,
     $session_id,                    $ui_formcount,             $user_module_config_directory);

do(dirname(__FILE__) . "/authentic-init.pm");

sub theme_header
{

    (get_raw() && return);
    my $tref = ref($_[0]) eq 'ARRAY';
    my $ttitle = $tref ? $_[0]->[0] : $_[0];
    embed_header(
        (($ttitle ne $title ? "$ttitle - $title" : $ttitle), $_[7], theme_debug_mode(), (@_ > 1 ? '1' : '0'), ($tref ? 1 : 0)
        ));
    print '<body ' . header_body_data(undef) . ' ' . $tconfig{'inbody'} . '>' . "\n";
    embed_overlay_prebody();
    if (@_ > 1 && $_[1] ne 'stripped') {

        # Print default container
        print ' <div class="container-fluid col-lg-10 col-lg-offset-1" data-dcontainer="1">' . "\n";
        my %this_module_info = &get_module_info(&get_module_name());
        print '<div class="panel panel-default">' . "\n";
        print '<div class="panel-heading">' . "\n";
        print $tconfig{'preheader'};
        print "<table class=\"header\"><tr>\n";

        print '<td id="headln2l" class="invisible">';
        if (!$_[5] && !$tconfig{'noindex'}) {
            my @avail = &get_available_module_infos(1);
            my $nolo = get_env('anonymous_user') ||
              get_env('ssl_user')   ||
              get_env('local_user') ||
              get_env('http_user_agent') =~ /webmin/i;
            if ($gconfig{'gotoone'} &&
                $main::session_id &&
                @avail == 1 &&
                !$nolo)
            {
                print
                  "<a href='$gconfig{'webprefix'}/session_login.cgi?logout=1'>",
                  "$text{'main_logout'}</a><br>";
            } elsif ($gconfig{'gotoone'} && @avail == 1 && !$nolo) {
                print "<a href=$gconfig{'webprefix'}/switch_user.cgi>", "$text{'main_switch'}</a><br>";
            }

        }
        if (!$_[4] && !$tconfig{'nomoduleindex'}) {
            my $idx = $this_module_info{'index_link'};
            my $mi  = $module_index_link || "/" . &get_module_name() . "/$idx";
            my $mt  = $module_index_name || $text{'header_module'};
            print "<a href=\"$gconfig{'webprefix'}$mi\">$mt</a><br>\n";
        }
        if (ref($_[2]) eq "ARRAY" &&
            !get_env('anonymous_user') &&
            !$tconfig{'nohelp'})
        {
            print &hlink($text{'header_help'}, $_[2]->[0], $_[2]->[1]), "<br>\n";
        } elsif (defined($_[2]) &&
                 !get_env('anonymous_user') &&
                 !$tconfig{'nohelp'})
        {
            print &hlink($text{'header_help'}, $_[2]), "<br>\n";
        }
        if ($_[3]) {
            my %access = &get_module_acl();
            if (!$access{'noconfig'} && !$config{'noprefs'}) {
                my $cprog =
                  $user_module_config_directory ? "uconfig.cgi" :
                  "config.cgi";
                print "<a href=\"$gconfig{'webprefix'}/$cprog?", &get_module_name() . "\">", $text{'header_config'},
                  "</a><br>\n";
            }
        }
        print "</td>\n";
        if ($_[1]) {
            print "<td data-current-module-name=\"$this_module_info{'desc'}\" id=\"headln2c\">",
              "<img alt=\"$ttitle\" src=\"$_[1]\"></td>\n";
        } else {
            my $ts =
              defined($tconfig{'titlesize'}) ? $tconfig{'titlesize'} :
              "+2";
            print "<td data-current-module-name=\"$this_module_info{'desc'}\" id='headln2c'>",
              ($ts ? "<span data-main_title>" : ""), $ttitle, ($ts ? "</span>" : "");
            print "<br>$_[9]\n" if ($_[9]);
            print "</td>\n";
        }
        print "<td id=\"headln2r\">";
        print $_[6];
        print "</td></tr></table>\n";
        print $tconfig{'postheader'};
        print '</div>' . "\n";
        print '<div class="panel-body">' . "\n";
    }
    $miniserv::page_capture = 1;
}

sub theme_footer
{
    (get_raw() && return);
    my %this_module_info = &get_module_info(&get_module_name());
    for (my $i = 0; $i + 1 < @_; $i += 2) {
        my $url = $_[$i];
        if ($url ne '/' || !$tconfig{'noindex'}) {
            if ($url eq '/') {
                $url = "/?cat=$this_module_info{'category'}";
            } elsif ($url eq '' && &get_module_name()) {
                $url = "/" . &get_module_name() . "/" . $this_module_info{'index_link'};
            } elsif ($url =~ /^\?/ && &get_module_name()) {
                $url = "/" . &get_module_name() . "/$url";
            }
            $url = "$gconfig{'webprefix'}$url" if ($url =~ /^\//);
            $url = $url . "/" if ($url =~ /[^\/]$/ && $url !~ /.cgi/ && $url !~ /javascript:history/);
            print
"&nbsp;<a style='margin-bottom: 15px;' class='btn btn-primary btn-lg page_footer_submit' href=\"$url\"><i class='fa fa-fw fa-arrow-left'>&nbsp;</i> ",
              &text('main_return', $_[$i + 1]), "</a>\n";
        }
    }

    print "</div>\n";
    embed_port_shell();
    embed_footer((theme_debug_mode()),
                 (
                  (get_module_name()                                                  ||
                     get_env('request_uri') =~ /\/config.cgi\?/                       ||
                     get_env('request_uri') =~ /\/uconfig.cgi\?/                      ||
                     get_env('request_uri') =~ /\/webmin_search.cgi\?/                ||
                     get_env('request_uri') =~ /\/settings-user.cgi/                  ||
                     get_env('request_uri') =~ /\/settings-editor_read.cgi/           ||
                     get_env('request_uri') =~ /\/settings-editor_favorites_read.cgi/ ||
                     get_env('request_uri') =~ /\/settings-logos.cgi/                 ||
                     get_env('request_uri') =~ /\/settings-backgrounds.cgi/
                  ) ? '1' : '0'
                 ),
                 $_[0]);
    embed_pm_scripts();

    if (get_env('script_name') eq '/session_login.cgi' ||
        get_env('script_name') eq '/pam_login.cgi')
    {
        embed_js_scripts();
    }

    if ($theme_config{'settings_hide_top_loader'} ne 'true' &&
        get_env('script_name') ne '/session_login.cgi' &&
        get_env('script_name') ne '/pam_login.cgi')
    {
        print '<div class="top-aprogress"></div>', "\n";
    }

    # Post-body header overlay
    embed_overlay_postbody();

    print '</body>', "\n";
    print '</html>', "\n";
}

sub theme_popup_prehead
{
    print '<style>#popup .ui_form_end_submit {display: none}</style>';
}

sub theme_file_chooser_button
{
    my $chroot = defined($_[3]) ? $_[3] : "/";
    my $add    = int($_[4]);
    my $link   = "chooser.cgi?add=$add&type=$_[1]&chroot=$chroot&file=\"+encodeURIComponent(ifield.value)";
    my $icon   = 'fa-fw fa-files-o';

    return get_chooser_button_template($link, $icon);
}

sub theme_user_chooser_button
{
    my $link = "user_chooser.cgi?multi=$_[1]&user=\"+encodeURIComponent(ifield.value)";
    my $icon = 'fa-user-o';

    return get_chooser_button_template($link, $icon);
}

sub theme_group_chooser_button
{
    my $link = "group_chooser.cgi?multi=$_[1]&group=\"+encodeURIComponent(ifield.value)";
    my $icon = 'fa-group-o';
    return get_chooser_button_template($link, $icon);
}

sub theme_interfaces_chooser_button
{
    my $link = "net/interface_chooser.cgi?multi=$_[1]&interface=\"+encodeURIComponent(ifield.value)";
    my $icon = 'fa2 fa2-plus-network';
    return get_chooser_button_template($link, $icon);
}

sub theme_date_chooser_button
{
    return
"<button data-day=\"$_[0]\" data-month=\"$_[1]\" data-year=\"$_[2]\" type=button class=\"btn btn-default heighter-28 chooser_button date_chooser_button\"><i class=\"fa fa-fw fa-calendar\"></i></button>\n";
}

sub theme_popup_window_button
{
    my ($url, $w, $h, $scroll, $fields) = @_;
    my $scrollyn = $scroll ? "yes" : "no";
    my $icon = "fa-files-o";
    if ($url =~ /third_chooser|standard_chooser/) {
        $icon = "fa-world";
    }

    my $rv = "<button class='btn btn-default chooser_button' type=button onClick='";
    foreach my $m (@$fields) {
        $rv .= "$m->[0] = form.$m->[1]; ";
    }
    my $sep = $url =~ /\?/ ? "&" : "?";
    $rv .= "chooser = window.open(\"$url\"";
    foreach my $m (@$fields) {
        if ($m->[2]) {
            $rv .= "+\"$sep$m->[2]=\"+encodeURIComponent($m->[0].value)";
            $sep = "&";
        }
    }
    $rv .= ", \"chooser\", \"toolbar=no,menubar=no,scrollbars=$scrollyn,resizable=yes,width=$w,height=$h\"); ";
    foreach my $m (@$fields) {
        $rv .= "chooser.$m->[0] = $m->[0]; ";
        $rv .= "window.$m->[0] = $m->[0]; ";
    }
    $rv .= "'><i class=\"fa $icon vertical-align-middle\" ></i></button>";
    return $rv;
}

sub theme_ui_upload
{
    my ($name, $size, $dis, $tags, $multiple) = @_;
    $size = &ui_max_text_width($size);
    return "<input class='ui_upload' type=file name=\"" .
      &quote_escape($name) . "\" " . "size=$size " . ($dis ? "disabled=true" : "") . ($multiple ? " multiple" : "") .
      ($tags ? " " . $tags : "") . ">";
}

sub theme_icons_table
{
    my $hide_table_icons = ($theme_config{'settings_right_hide_table_icons'} eq 'true' ? 1 : 0);
    print '<div class="row icons-row' . (!$hide_table_icons && ' vertical-align') . '">' . "\n";
    for (my $i = 0; $i < @{ $_[0] }; $i++) {

        $hide_table_icons &&
          print '<div style="margin-bottom: -5px; text-align: left;" class="col-sm-3">' . "\n";
        &generate_icon($_[2]->[$i], $_[1]->[$i], $_[0]->[$i], ref($_[4]) ? $_[4]->[$i] : $_[4],
                       $_[5], $_[6], $_[7]->[$i], $_[8]->[$i]);

        $hide_table_icons && print '</div>' . "\n";
    }
    print '</div>' . "\n";
}

sub theme_generate_icon
{
    my ($icon, $title, $link, $href, $width, $height, $before, $after) = @_;
    if ($theme_config{'settings_right_hide_table_icons'} eq 'true') {
        print '<div>';
        print $before;
        print '<a' . ($before ? ' class="inline-block"' : ' ') .
          'href="' . $link . '" ' . $href . '><p><i class="fa fa-fw fa-angle-right' .
          ($before ? ' hidden' : '') . '">&nbsp;&nbsp;</i>' . $title . '</p></a>';
        print $after;
        print '</div>';
    } else {
        my $icon_outer = $icon;
        my $wp         = $gconfig{'webprefix'};

        $icon =~ s/^$wp//g if ($wp);
        $icon =~ s/\/images//g;
        $icon =~ s/images//g;

        my $grayscaled_table_icons = ($theme_config{'settings_right_grayscaled_table_icons'} ne 'false' ? 0 : 1);
        my $animate_table_icons = ($theme_config{'settings_right_animate_table_icons'} ne 'false' ? 0 :
                                     1);
        (my $___svg = $icon) =~ s/.gif/.svg/;

        (!-r $root_directory . "/" . get_module_name() . "/" . $icon_outer) &&
          ($icon_outer = undef);

        my $mod            = get_module_name();
        my $images_modules = 'images/modules';
        my $root_images    = $root_directory . "/$current_theme/$images_modules/";
        my $__icon = (-r $root_images . $icon            ? $wp . "/$images_modules" . $icon :
                        -r $root_images . $mod . $icon   ? $wp . "/$images_modules/" . $mod . $icon :
                        -r $root_images . $mod . $___svg ? $wp . "/$images_modules/" . $mod . $___svg :
                        $icon_outer                      ? $icon_outer :
                        ($wp . "/images/not_found.svg"));

        if ($theme_config{'settings_right_small_table_icons'} eq 'true') {
            print '<div class="col-xs-1 small-icons-container' .
              (!$_[6] && !$_[7] ? ' forged-xx-skip' : ' gl-icon-container') .
              '' . (!$grayscaled_table_icons && ' grayscaled') . '' . (!$animate_table_icons && ' animated') .
              '" data-title="' . $title . '" data-toggle="tooltip" data-placement="auto top" data-container="body">';
            if ($_[6] || $_[7]) {
                if ($_[6]) {
                    print "<span class='hidden-forged hidden-forged-6'>$_[6]</span>\n";
                }
                if ($_[7]) {
                    print
"<span style='position: absolute; top:-2px; right: 2px;' class='hidden-forged hidden-forged-7 hidden-forged-7-small'>$_[7]</span>\n";
                }
            }
            print "<a href=\"$link\" class=\"icon_link\">" . '<img class="ui_icon' .
              ($icon_outer && ' ui_icon_protected') . '" src="' . $__icon . '" alt="">';
            print "<span class=\"hidden\">$title</span></a>\n";
            print '</div>';
        } else {
            print '<div class="col-xs-1 icons-container' . (!$_[6] && !$_[7] ? ' forged-xx-skip' : ' gl-icon-container') .
              '' . (!$grayscaled_table_icons && ' grayscaled') . '' . (!$animate_table_icons && ' animated') .
              '" data-title="' . (($theme_config{'settings_right_small_table_icons'} eq 'true') ? $title : '') .
              '" data-toggle="tooltip" data-placement="auto top" data-container="body">';
            if ($_[6] || $_[7]) {
                if ($_[6]) {
                    print "<span class='hidden-forged hidden-forged-6' forged-xx-data forged-xx-sub>$_[6]</span>\n";
                }
                if ($_[7]) {
                    print
"<span style='position: absolute; top:2px; right: 4px;' class='hidden-forged hidden-forged-7'>$_[7]</span>\n";
                }
            }
            print "<a href=\"$link\" class=\"icon_link\" data-title=\""
              .
              ( ($_[6] || $_[7]) ? $title :
                  (string_contains($title, '<tt') ? "<span class='word-break-all'>$title</span>" : undef)
              ) .
              "\" data-toggle=\"tooltip\" data-placement=\"auto bottom\" data-container=\"body\" " .
              (string_contains($title, '<tt') ? " data-fbplacement" : undef) . ">" . '<img class="ui_icon' .
              ($icon_outer && ' ui_icon_protected') . '" src="' . $__icon . '" alt=""><br>';
            print "$title</a>\n";
            print '</div>';
        }
    }
}

sub theme_ui_columns_start
{
    my ($heads, $width, $noborder, $tdtags, $title) = @_;
    my ($rv, $i);

    $rv .= '<table class="table table-striped table-hover table-condensed">' . "\n";
    if ($title) {
        $rv .= "<caption>$title</caption>\n";
    }
    $rv .= '<thead>' . "\n";
    $rv .= '<tr>' . "\n";
    if (ref($heads)) {
        for ($i = 0; $i < @$heads; $i++) {
            $rv .= "<th " . (ref($tdtags) ? $tdtags->[$i] : undef) . ">";
            $rv .= ($heads->[$i] eq '' ? '<br>' : $heads->[$i]);
            $rv .= '</th>' . "\n";
        }
    }
    $rv .= '</tr>' . "\n";
    $rv .= '</thead>' . "\n";
    $rv .= '<tbody>' . "\n";

    return $rv;
}

sub theme_ui_columns_row
{
    my ($cols, $tdtags) = @_;
    my ($rv, $i);

    $rv .= '<tr class="tr_tag">' . "\n";
    if (ref($cols)) {
        for ($i = 0; $i < @$cols; $i++) {
            $rv .= "<td data-td-e " . (ref($tdtags) ? $tdtags->[$i] : undef) . ">\n";
            $rv .= ($cols->[$i] !~ /\S/ ? '<br>' : $cols->[$i]);
            $rv .= '</td>' . "\n";
        }
    }
    $rv .= '</tr>' . "\n";

    return $rv;
}

sub theme_ui_columns_header
{
    my ($cols, $tdtags) = @_;
    my ($rv, $i);

    $rv .= '<thead>' . "\n";
    $rv .= '<tr>' . "\n";
    if (ref($cols)) {
        for ($i = 0; $i < @$cols; $i++) {
            $rv .= "<th " . (ref($tdtags) ? $tdtags->[$i] : undef) . ">";
            $rv .= ($cols->[$i] eq '' ? '#' : $cols->[$i]);
            $rv .= '</th>' . "\n";
        }
    }
    $rv .= '</tr>' . "\n";
    $rv .= '</thead>' . "\n";

    return $rv;
}

sub theme_ui_columns_end
{
    my $rv;

    $rv .= '</tbody></table>' . "\n";

    return $rv;
}

sub theme_ui_link
{

    my ($href, $text, $class, $tags) = @_;
    return (
          "<a class='ui_link" . ($class ? " " . $class : "") . "' href='$href'" . ($tags ? " " . $tags : "") . ">$text</a>");
}

sub theme_ui_links_row
{

    my ($links, $nopuncs) = @_;
    my $link = "<a";
    if (ref($links)) {
        if (string_contains("@$links", $link)) {
            @$links =
              map {string_contains($_, $link) ? $_ : "<span class=\"btn btn-success ui_link ui_link_empty\">$_</span>"}
              @$links;
            return
              @$links ? "<div class=\"btn-group ui_links_row\" role=\"group\">" . join("", @$links) . "</div><br>\n" :
              "";
        } else {
            if ($nopuncs == 1) {
                return @$links ? join(", ", @$links) . "<br>\n" : "";
            } elsif ($nopuncs == 2) {
                return @$links ? join(" ", @$links) . "<br>\n" : "";
            } else {
                return @$links ? join(", ", @$links) . ".<br>\n" : "";
            }
        }
    }
}

sub theme_select_all_link
{

    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selall'};
    return "<a class='select_all' href='#' onclick='theme_select_all_link($form, \"$field\"); return false'>$text</a>";
}

sub theme_select_invert_link
{

    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selinv'};
    return "<a class='select_invert' href='#' onclick='theme_select_invert_link($form, \"$field\"); return false'>$text</a>";
}

sub theme_select_rows_link
{
    my ($field, $form, $text, $rows) = @_;
    $form = int($form);
    my $js = "var sel = { " . join(",", map {"\"" . &quote_escape($_) . "\":1"} @$rows) . " }; ";
    $js .=
"for(var i=0; i<document.forms[$form].${field}.length; i++) { var r = document.forms[$form].${field}[i]; r.checked = sel[r.value]; } ";
    $js .= "return false;";
    return "<a href='#' onClick='$js'>$text</a>";
}

sub theme_ui_form_start
{
    my ($script, $method, $target, $tags) = @_;
    my $rv;

    $rv .= '<form class="ui_form" ';
    $rv .= 'action="' . &html_escape($script) . '" ';
    $rv .= ($method eq 'post' ? 'method="post" ' :
              ($method eq 'form-data' ? 'method="post" enctype="multipart/form-data" ' : 'method="get" '));
    $rv .= ($target ? 'target="' . $target . '" ' : '');
    $rv .= ($tags   ? $tags                       : '');
    $rv .= '>' . "\n";

    return $rv;
}

sub theme_ui_form_end
{
    $ui_formcount++;
    my ($buttons, $width, $nojs) = @_;
    my $rv;
    if ($buttons && @$buttons) {
        $rv .= "<table class='ui_form_end_buttons' " . ($width ? " width=$width" : "") . "><tr><td>\n";
        my $b;
        $rv .= '<div class="btn-group end_submits">';
        foreach $b (@$buttons) {
            if (ref($b)) {
                $rv .= &ui_submit($b->[1], $b->[0], $b->[3], $b->[4]) . ($b->[2] ? " " . $b->[2] : "");
            } elsif ($b) {
                $rv .= "<span>$b</span>\n";
            } else {
                $rv .= "<span>&nbsp;</span>\n";
            }
        }
        $rv .= '</div>';
        $rv .= "</td></tr></table>\n";
    }
    $rv .= "</form>\n";
    if (!$nojs) {

        # When going back to a form, re-enable any text fields generated by
        # ui_opt_textbox that aren't in the default state.
        $rv .= "<script>\n";
        $rv .= "var opts = document.getElementsByClassName('ui_opt_textbox');\n";
        $rv .= "for(var i=0; i<opts.length; i++) {\n";
        $rv .= "  opts[i].disabled = document.getElementsByName(opts[i].name+'_def')[0].checked;\n";
        $rv .= "}\n";
        $rv .= "</script>\n";
    }
    return $rv;
}

sub theme_ui_textbox
{
    my ($name, $value, $size, $dis, $max, $tags) = @_;
    my $rv;

    $rv .=
'<input style="display: inline; width: auto; height: 28px; padding-top: 0; padding-bottom: 2px; vertical-align: middle" class="form-control ui_textbox" type="text" ';
    $rv .= 'id="' . &quote_escape($name) . '" ';
    $rv .= 'name="' . &quote_escape($name) . '" ';
    $rv .= 'value="' . &quote_escape($value) . '" ';
    $rv .= 'size="' . $size . '" ';
    $rv .= ($dis ? 'disabled="true" ' : '');
    $rv .= ($max ? 'maxlength="' . $max . '" ' : '');
    $rv .= ($tags ? $tags : '');
    $rv .= '>' . "\n";

    return $rv;
}

sub theme_ui_password
{
    my ($name, $value, $size, $dis, $max, $tags) = @_;
    my $rv;

    $rv .=
'<input style="display: inline; width: auto; height: 28px; padding-top: 0; padding-bottom: 2px; vertical-align:middle" class="form-control ui_password" type="password" ';
    $rv .= 'name="' . &quote_escape($name) . '" ';
    $rv .= 'value="' . &quote_escape($value) . '" ';
    $rv .= 'size="' . $size . '" ';
    $rv .= ($dis ? 'disabled="true" ' : '');
    $rv .= ($max ? 'maxlength="' . $max . '" ' : '');
    $rv .= ($tags ? $tags : '');
    $rv .= '>' . "\n";

    return $rv;
}

sub theme_ui_page_flipper
{
    my ($msg, $inputs, $cgi, $left, $right, $farleft, $farright, $below) = @_;
    my $rv    = "<center class='ui_page_flipper'>";
    my $class = 'fa fa-fw fa-lg text-semi-light vertical-align-baseline';
    $rv .= &ui_form_start($cgi) if ($cgi);

    # Far left link, if needed
    if (@_ > 5) {
        if ($farleft) {
            $rv .=
              "<a href='$farleft'>" . "<i " . get_button_tooltip('right_pagination_first', undef, 'auto top') .
              "class='$class fa-angle-double-left'></i></a>\n";
        } else {
            $rv .= "<i class='$class fa-angle-double-left disabled'></i>\n";
        }
    }

    # Left link
    if ($left) {
        $rv .=
          "<a href='$left'>" . "<i " . get_button_tooltip('extensions_mail_pagination_left', undef, 'auto top') .
          "class='$class fa-angle-left'></i></a>\n";
    } else {
        $rv .= "<i class='$class fa-angle-left disabled'></i>\n";
    }

    # Message and inputs
    $rv .= $msg;
    $rv .= " " . $inputs if ($inputs);

    # Right link
    if ($right) {
        $rv .=
          "<a href='$right'>" . "<i " . get_button_tooltip('extensions_mail_pagination_right', undef, 'auto top') .
          "class='$class fa-angle-right'></i></a>\n";
    } else {
        $rv .= "<i class='$class fa-angle-right disabled'></i>\n";
    }

    # Far right link, if needed
    if (@_ > 5) {
        if ($farright) {
            $rv .=
              "<a href='$farright'>" . "<i " . get_button_tooltip('right_pagination_last', undef, 'auto top') .
              "class='$class fa-angle-double-right'></i></a>\n";
        } else {
            $rv .= "<i class='$class fa-angle-double-right disabled'></i>\n";
        }
    }

    $rv .= "<br>" . $below if ($below);
    $rv .= &ui_form_end()  if ($cgi);
    $rv .= "</center>\n";
    return $rv;
}

sub theme_ui_select
{

    my ($name, $value, $opts, $size, $multiple, $missing, $dis, $tags) = @_;
    my $rv;
    $rv .=
      "<select class='ui_select' " . "name=\"" . &quote_escape($name) .
      "\" " . ($size ? " size='$size'" : "") . ($multiple ? " multiple" : "") . ($dis ? " disabled=true" : "") .
      ($tags ? " " . $tags : "") . ">\n";
    my ($o, %opt, $s, $v);
    my %sel = ref($value) ? (map {$_, 1} @$value) : ($value, 1);
    my $t = 'x-md-';
    foreach $o (@$opts) {
        $o = [$o] if (!ref($o));
        $v = ($o->[1] || $o->[0]);
        $rv .=
          "<option value=\"" .
          &quote_escape($o->[0]) . "\"" . ($sel{ $o->[0] } ? " selected" : "") . ($o->[2] ne '' ? " " . $o->[2] : "") . ">" .
          (string_contains($v, $t) ? html_escape($v) : $v) . "</option>\n";
        $opt{ $o->[0] }++;
    }
    foreach $s (keys %sel) {
        if (!$opt{$s} && $missing) {
            $rv .= "<option value=\"" . &quote_escape($s) . "\"" . " selected>" .
              ($s eq "" ? "&nbsp;" : (string_contains($s, $t) ? html_escape($s) : $s)) . "</option>\n";
        }
    }
    $rv .= "</select>\n";
    return $rv;
}

sub theme_ui_radio
{
    my ($name, $val, $opts, $dis) = @_;
    my ($rv, $o);
    my $rand = int rand(1e4);
    foreach $o (@$opts) {
        my $id = &quote_escape($name . "_" . $o->[0]);
        my $label = $o->[1] || $o->[0];
        my $after;
        if ($label =~ /^([\000-\377]*?)((<a\s+href|<input|<select|<textarea)[\000-\377]*)$/i) {
            $label = $1;
            $after = $2;
        }
        $rv .= '<span class="awradio awobject"><input class="iawobject" type="radio" ';
        $rv .= 'name="' . &quote_escape($name) . '" ';
        $rv .= 'value="' . &quote_escape($o->[0]) . '" ';
        $rv .= ($o->[0] eq $val ? 'checked ' : '');
        $rv .= ($dis ? 'disabled="true" ' : '');
        $rv .= 'id="' . $id . '_' . $rand . '" ';
        $rv .= $o->[2] . ' ';
        $rv .= '>' . "\n";
        $rv .= '<label class="lawobject" ';
        $rv .= 'for="' . $id . '_' . $rand . '">' . "\n";
        $rv .= '' . (length trim($label) ? trim($label) : '&nbsp;') . "\n";
        $rv .= '</label></span>' . $after . "\n";
    }

    return $rv;
}

sub theme_ui_yesno_radio
{
    my ($name, $value, $yes, $no, $dis) = @_;
    $yes = 1 if (!defined($yes));
    $no  = 0 if (!defined($no));
    if ($value =~ /^[0-9,.E]+$/ || !$value) {
        $value = int($value);
    }
    return ui_radio($name, $value, [[$yes, $text{'yes'}], [$no, $text{'no'}]], $dis);
}

sub theme_ui_oneradio
{
    my ($name, $value, $label, $sel, $tags, $dis) = @_;
    my $id = &quote_escape("${name}_${value}");
    my $after;
    my $rand = int rand(1e4);

    if ($label =~ /^([^<]*)(<[\000-\377]*)$/) {
        $label = $1;
        $after = $2;
    }
    my $ret =
      "<span class=\"awradio awobject\"><input class=\"iawobject\" type=\"radio\" name=\"" .
      &quote_escape($name) . "\" " . "value=\"" .
      &quote_escape($value) . "\" " . ($sel ? " checked" : "") . ($dis ? " disabled=true" : "") . " id=\"$id\_$rand\"" .
      ($tags ? " " . $tags : "") . ">";
    $ret .=
      ' <label class="lawobject" for="' . $id . '_' . $rand . '">' .
      (length trim($label) ? trim($label) : '&nbsp;') . '</label></span>';
    $ret .= "$after\n";
    return $ret;
}

sub theme_ui_checkbox
{
    return theme_ui_checkbox_local(@_);
}

sub theme_ui_textarea
{
    my ($name, $value, $rows, $cols, $wrap, $dis, $tags) = @_;
    $cols = &ui_max_text_width($cols, 1);

    return "<textarea style='display: inline; width:100%;' class='form-control ui_textarea' " .
      "name=\"" . &quote_escape($name) . "\" " . "id=\"" . &quote_escape($name) .
      "\" " . "rows='$rows' cols='$cols'" . ($wrap ? " wrap=$wrap" : "") . ($dis ? " disabled=true" : "") .
      ($tags ? " $tags" : "") . ">" . &html_escape($value) . "</textarea>";
}

sub theme_ui_submit
{
    my ($label, $name, $dis, $tags) = @_;
    my ($keys, $class, $icon) = get_button_style($label);

    return "<button class=\"btn btn-" . $class .
      " ui_submit ui_form_end_submit\" type=\"button\"" . ($name ne '' ? " name=\"" . &quote_escape($name) . "\"" : "") .
      ($name ne '' ? " id=\"" . &quote_escape($name) . "\"" : "") .
      ($dis ? " disabled=true" : "") . ($tags ? " " . $tags : "") . ">" . $icon . "&nbsp;<span data-entry=\"$keys\">" .
      &quote_escape($label) . "&nbsp;</span></button>\n" . "<input class=\"hidden\" type=\"submit\""
      .
      ( $name ne '' ? " name=\"" . &quote_escape($name) . "\" value=\"" . &quote_escape($label) . "\"" :
          ""
      ) .
      " >\n";
}

sub theme_ui_reset
{
    my ($label, $dis) = @_;
    my $rv;

    $rv .= '<button class="btn btn-default ui_reset" style="height: 28px; vertical-align:middle" type="reset" ';
    $rv .= ($dis ? 'disabled="disabled">' : '>');
    $rv .= &quote_escape($label);
    $rv .= '</button>' . "\n";

    return $rv;
}

sub theme_ui_button
{
    my ($label, $name, $dis, $tags) = @_;
    my $rv;

    $rv .= '<button type="button" class="btn btn-default ui_button" ';
    $rv .= ($name ne '' ? 'name="' . &quote_escape($name) . '" ' : '');
    $rv .= ($dis ? 'disabled="disabled"' : '');
    $rv .= ($tags ? ' ' . $tags : '') . '>';
    $rv .= &quote_escape($label);
    $rv .= '</button>' . "\n";

    return $rv;
}

sub theme_ui_post_header
{
    my ($text) = @_;
    my $rv;

    if (defined($text)) {
        $rv = '<span class="ui_post_header hidden"><br>' . $text . '</span>';
    }

    return $rv;
}

sub theme_ui_pre_footer
{
    my $rv;
    $rv .= '</div>' . "\n";
    $rv .= '</div>' . "\n";

    return $rv;
}

sub theme_ui_tabs_start
{
    my ($tabs, $name, $sel, $border) = @_;
    my $rv;

    $rv .= '<ul class="nav nav-tabs">' . "\n";
    foreach my $t (@$tabs) {
        if ($t->[0] eq $sel) {
            $rv .=
              '<li class="active"><a data-toggle="tab" onclick="return tab_action(\'' .
              $name . '\', \'' . $t->[0] . '\')" href="#att_' . $t->[0] . '">' . $t->[1] . '</a></li>' . "\n";
        } else {
            $rv .=
              '<li><a data-toggle="tab" onclick="return tab_action(\'' .
              $name . '\', \'' . $t->[0] . '\')" href="#att_' . $t->[0] . '">' . $t->[1] . '</a></li>' . "\n";
        }
    }
    $rv .= '</ul>' . "\n";
    $rv .= '<div class="tab-content">' . "\n";
    $main::ui_tabs_selected = $sel;
    $rv .= &ui_hidden($name, $sel) . "\n";

    return $rv;
}

sub theme_ui_tabs_end
{
    my ($border) = @_;
    my $rv;

    $rv .= '</div>' . "\n";

    return $rv;
}

sub theme_ui_tabs_start_tab
{
    my ($name, $tab) = @_;
    my $rv;
    my $defclass = $tab eq $main::ui_tabs_selected ? 'active' : '';

    $rv .= '<div id="att_' . $tab . '" class="tab-pane ' . $defclass . '">' . "\n";

    return $rv;
}

sub theme_ui_tabs_end_tab
{
    my $rv;

    $rv .= '</div>' . "\n";

    return $rv;
}

sub theme_ui_hr
{
    my $rv;

    $rv .= '<hr>' . "\n";

    return $rv;
}

sub theme_ui_alert_box
{
    my ($msg, $class, $style, $new_line, $desc_to_title) = @_;
    my ($rv, $type, $tmsg, $fa);

    if ($class eq "success") {
        $type = 'alert-success', $tmsg = ($theme_text{'theme_global_success'} . '!'), $fa = 'fa-check-circle';
    } elsif ($class eq "info") {
        $type = 'alert-info', $tmsg = ($theme_text{'theme_global_info'} . '!'), $fa = 'fa-info-circle';
    } elsif ($class eq "warn") {
        $type = 'alert-warning', $tmsg = ($theme_text{'theme_global_warning'} . '!'), $fa = 'fa-exclamation-circle';
    } elsif ($class eq "danger") {
        $type = 'alert-danger', $tmsg = ($theme_text{'theme_xhred_global_error'} . '!'), $fa = 'fa-bolt';
    }

    if ($desc_to_title) {
        $tmsg = $desc_to_title;
    }

    $rv .= '<div class="alert ' . $type . '" style=" ' . $style . '">' . "\n";
    $rv .= '<i class="fa fa-fw ' . $fa . '"></i> <strong>' . $tmsg . '</strong>';
    $rv .= ($new_line ? '<br>' : '&nbsp;') . "\n";
    $rv .= $msg . "\n";
    $rv .= '</div>' . "\n";

    return $rv;
}

sub theme_ui_table_start
{
    my ($heading, $tabletags, $cols, $tds, $rightheading) = @_;
    if (defined($main::ui_table_cols)) {

        push(@main::ui_table_cols_stack,        $main::ui_table_cols);
        push(@main::ui_table_pos_stack,         $main::ui_table_pos);
        push(@main::ui_table_default_tds_stack, $main::ui_table_default_tds);
    }
    my $colspan = 1;
    my $rv;
    $rv .= "<div class='table-responsive'><table class='table table-striped table-condensed table-subtable' $tabletags>\n";
    if (defined($heading) || defined($rightheading)) {
        $rv .= "<thead><tr>";
        if (defined($heading)) {
            $rv .= "<th class='table-title'><b>$heading</b></th>";
        }
        if (defined($rightheading)) {
            $rv .= "<th>$rightheading</th>";
            $colspan++;
        }
        $rv .= "</tr></thead>\n";
    }
    $rv .= "<tbody> <tr><td>" . "<table class='sub_table_container' width=100%>\n";
    $main::ui_table_cols        = $cols || 4;
    $main::ui_table_pos         = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

sub theme_ui_table_end
{
    my $rv;
    if ($main::ui_table_cols == 4 && $main::ui_table_pos) {

        $rv .= &ui_table_row(" ", " ");
    }
    if (@main::ui_table_cols_stack) {
        $main::ui_table_cols        = pop(@main::ui_table_cols_stack);
        $main::ui_table_pos         = pop(@main::ui_table_pos_stack);
        $main::ui_table_default_tds = pop(@main::ui_table_default_tds_stack);
    } else {
        $main::ui_table_cols        = undef;
        $main::ui_table_pos         = undef;
        $main::ui_table_default_tds = undef;
    }
    $rv .= "</table></td></tr></tbody></table></div>\n";
    return $rv;
}

sub theme_ui_table_row
{
    my ($label, $value, $cols, $tds) = @_;
    $cols ||= 1;
    $tds  ||= $main::ui_table_default_tds;
    my $rv;
    if ($main::ui_table_pos + $cols + 1 > $main::ui_table_cols &&
        $main::ui_table_pos != 0)
    {
        $rv .= "</tr>\n";
        $main::ui_table_pos = 0;
    }
    $rv .= "<tr>\n"
      if ($main::ui_table_pos % $main::ui_table_cols == 0);
    $rv .= "<td class='col_label'><b>$label</b></td>\n"
      if (defined($label));
    $rv .= '<td colspan="' . $cols . '" class="col_value' . (!length($label) && ' col_header') . '">' . $value . '</td>';
    $main::ui_table_pos += $cols + (defined($label) ? 1 : 0);
    if ($main::ui_table_pos % $main::ui_table_cols == 0) {
        $rv .= "</tr>\n";
        $main::ui_table_pos = 0;
    }
    return $rv;
}

sub theme_ui_table_hr
{
    my $rv;
    if ($main::ui_table_pos) {
        $rv .= "</tr>\n";
        $main::ui_table_pos = 0;
    }
    $rv .= "<tr> " . "<td colspan=$main::ui_table_cols class='no-border'><hr></td></tr>\n";
    return $rv;
}

sub theme_ui_opt_textbox
{
    my ($name, $value, $size, $opt1, $opt2, $dis, $extra, $max, $tags) = @_;
    my $dis1 = &js_disable_inputs([$name, (defined($extra) ? @$extra : ())], []);
    my $dis2 = &js_disable_inputs([], [$name, (defined($extra) ? @$extra : ())]);
    my $rv;
    $size = &ui_max_text_width($size);
    $rv .= &ui_radio($name . "_def",
                     $value eq '' ? 1 : 0,
                     [[1, $opt1, "onClick='$dis1'"], [0, $opt2 || " ", "onClick='$dis2'"]], $dis) .
      "\n";
    $rv .=
"<span><input class='ui_opt_textbox form-control' style='display: inline; width: auto; height: 28px; padding-top: 0; padding-bottom: 2px; min-width: 15%;' type='text' name=\""
      . &quote_escape($name)
      . "\" " . "size=$size value=\"" .
      &quote_escape($value) . "\"" . ($dis ? " disabled=true" : "") . ($max ? " maxlength=$max" : "") .
      ($tags ? " " . $tags : "") . "></span>";
    return $rv;
}

sub theme_ui_checked_columns_row
{
    my ($cols, $tdtags, $checkname, $checkvalue, $checked, $disabled, $tags) = @_;
    my $rv;
    $rv .= "<tr" . ($cb ? " " . $cb : "") . " class='ui_checked_columns'>\n";
    $rv .=
      "<td class='ui_checked_checkbox' " . (ref($tdtags) ? $tdtags->[0] : '') .
      ">" . &ui_checkbox($checkname, $checkvalue, undef, $checked, $tags, $disabled) . "</td>\n";
    my $i;
    for ($i = 0; $i < @$cols; $i++) {
        $rv .= "<td " . (ref($tdtags) ? $tdtags->[$i + 1] : '') . ">";
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
            $rv .= "<label for=\"" . &quote_escape("${checkname}_${checkvalue}") . "\">";
        }
        $rv .= ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i]);
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea/) {
            $rv .= "</label>";
        }
        $rv .= "</td>\n";
    }
    $rv .= "</tr>\n";
    return $rv;
}

sub theme_ui_hidden_javascript
{
    my $rv;
    my ($jscb, $jstb) = ($cb, $tb);
    $jscb =~ s/'/\\'/g;
    $jstb =~ s/'/\\'/g;
    return undef;
}

sub theme_ui_hidden_start
{

    my ($title, $name, $status, $url) = @_;
    my $rv;
    if (!$main::ui_hidden_start_donejs++) {
        $rv .= &ui_hidden_javascript();
    }
    my $divid    = "hiddendiv_$name";
    my $openerid = "hiddenopener_$name";
    my $defclass = $status ? 'opener_shown' : 'opener_hidden';
    $rv .= "<a class=\"hidden\" href=\"javascript:hidden_opener('$divid', '$openerid')\" id='$openerid'></a>\n";
    $rv .= "<a href=\"javascript:hidden_opener('$divid', '$openerid')\">$title</a><br>\n";
    $rv .= "<div class='$defclass' id='$divid'>\n";
    return $rv;
}

sub theme_ui_hidden_table_start
{
    my ($heading, $tabletags, $cols, $name, $status, $tds, $rightheading) = @_;
    my $rv;
    if (!$main::ui_hidden_start_donejs++) {
        $rv .= &ui_hidden_javascript();
    }
    my $divid    = "hiddendiv_$name";
    my $openerid = "hiddenopener_$name";
    my $defclass =
      $status ? 'opener_shown' :
      'opener_hidden';
    my $text =
      defined($tconfig{'cs_text'}) ? $tconfig{'cs_text'} :
      defined($gconfig{'cs_text'}) ? $gconfig{'cs_text'} :
      "f00";
    $rv .= "<table class='table table-striped table-hover table-condensed' $tabletags>\n";
    my $colspan = 1;

    if (defined($heading) || defined($rightheading)) {
        $rv .= "<tr" . ($tb ? " " . $tb : "") . "><td>";
        if (defined($heading)) {
            $rv .=
"<a class='opener_trigger' href=\"javascript:hidden_opener('$divid', '$openerid')\" id='$openerid'></a> <a class='opener_trigger' href=\"javascript:hidden_opener('$divid', '$openerid')\">$heading</a></td>";
        }
        if (defined($rightheading)) {
            $rv .= "<td align=right>$rightheading</td>";
            $colspan++;
        }
        $rv .= "</td> </tr>\n";
    }
    $rv .=
      "<tr" . ($cb ? " " . $cb : "") .
      "><td class='opener_container' colspan=$colspan><div class='$defclass' id='$divid'><table width=100%>\n";
    $main::ui_table_cols        = $cols || 4;
    $main::ui_table_pos         = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

sub theme_ui_buttons_start
{
    return "<table width='100%' class='ui_buttons_table'>\n<tr><td>";
}

sub theme_ui_buttons_row
{
    my ($script, $label, $desc, $hiddens, $after, $before) = @_;
    if (ref($hiddens)) {
        $hiddens = join("\n", map {&ui_hidden(@$_)} @$hiddens);
    }
    return "<form action='$script' method='post' class='ui_buttons_form'>\n" .
      $hiddens . "<table>" . "<tr class='ui_buttons_row'> " . "<td data-nowrap class=ui_buttons_label>" .
      ($before ? $before . " " : "") . &ui_submit($label) . ($after ? " " . $after : "") .
      "</td>\n" . "<td class=ui_buttons_value>" . $desc . "</td></tr>\n" . "</table>\n" . "</form>\n";
}

sub theme_ui_buttons_end
{
    return "</td></tr></table>\n";
}

sub theme_ui_radio_table
{
    my ($name, $sel, $rows, $nobold) = @_;
    return "" if (!@$rows);
    my $rv = "<table class='ui_radio_table'>\n";
    foreach my $r (@$rows) {
        $rv .= "<tr>\n";
        $rv .=
          "<td" . (defined($r->[2]) ? "" : " colspan=2") .
          ">" . ($nobold ? "" : "<b>") . &ui_oneradio($name, $r->[0], $r->[1], $r->[0] eq $sel, $r->[3]) .
          ($nobold ? "" : "</b>") . "</td>\n";
        if (defined($r->[2])) {
            $rv .= "<td>" . $r->[2] . "</td>\n";
        }
        $rv .= "</tr>\n";
    }
    $rv .= "</table>\n";
    return $rv;
}

sub theme_make_date
{
    return theme_make_date_local(@_);
}

sub theme_nice_size
{
    my ($units, $uname);
    if (abs($_[0]) > 1024 * 1024 * 1024 * 1024 * 1024 || $_[1] >= 1024 * 1024 * 1024 * 1024 * 1024) {
        $units = 1024 * 1024 * 1024 * 1024 * 1024;
        $uname = $theme_text{'theme_nice_size_PB'};
    } elsif (abs($_[0]) > 1024 * 1024 * 1024 * 1024 || $_[1] >= 1024 * 1024 * 1024 * 1024) {
        $units = 1024 * 1024 * 1024 * 1024;
        $uname = $theme_text{'theme_nice_size_TB'};
    } elsif (abs($_[0]) > 1024 * 1024 * 1024 || $_[1] >= 1024 * 1024 * 1024) {
        $units = 1024 * 1024 * 1024;
        $uname = $theme_text{'theme_nice_size_GB'};
    } elsif (abs($_[0]) > 1024 * 1024 || $_[1] >= 1024 * 1024) {
        $units = 1024 * 1024;
        $uname = $theme_text{'theme_nice_size_MB'};
    } elsif (abs($_[0]) > 1024 || $_[1] >= 1024) {
        $units = 1024;
        $uname = $theme_text{'theme_nice_size_kB'};
    } else {
        $units = 1;
        $uname = $theme_text{'theme_nice_size_b'};
    }
    my $sz = sprintf("%.2f", ($_[0] * 1.0 / $units));
    $sz =~ s/\.00$//;

    if ($_[1] == -1) {
        return $sz . " " . $uname;
    } else {
        return '<span data-filesize-bytes="' . $_[0] . '">' . ($sz . " " . $uname) . '</span>';
    }
}

sub theme_redirect
{
    if ($ENV{'REQUEST_URI'} =~ /noredirect=1/) {
        head();
        return;
    }

    my $origin   = $ENV{'HTTP_ORIGIN'};
    my $referer  = $ENV{'HTTP_REFERER'};
    my $prefix   = $gconfig{'webprefix'};
    my $noredir  = $gconfig{'webprefixnoredir'};
    my $relredir = $gconfig{'relative_redir'};
    my ($arg1, $arg2) = ($_[0], $_[1]);
    my ($link) = $arg1 || $arg2;
    my ($url) = $arg2;
    if (!$relredir) {
        ($url) = $arg2 =~ /\/\/\S+?(\/\S*)/;
    }
    $url = "$prefix$url" if ($url && $noredir);

    my ($parent) = parse_servers_path();
    if ($parent) {
        ($link) = $arg2 =~ /:\d+(.*)/;
        $url = "$parent$link";
    } elsif ((string_starts_with($arg1, 'http') && ($arg1 !~ /$origin/ || $referer !~ /$arg1/))) {
        print "Location: $arg1\n\n";
        return;
    } elsif (string_contains($arg1, '../')) {
        set_theme_temp_data('redirected', $arg1) if ($arg1 !~ /switch\.cgi/);
        print "Location: $arg1\n\n";
        return;
    }

    if (!theme_redirect_download($url)) {
        set_theme_temp_data('redirected', $url);
        print "Location: $url\n\n";
    }
}

sub theme_header_redirect_download
{
    my ($url, $delay, $message) = @_;

    PrintHeader();
    print "<!DOCTYPE html>\n";
    print "<html>\n";
    print "<head>\n";
    print '<meta charset="' . get_charset() . '">', "\n";
    embed_favicon();
    print "</head>\n";
    my $script =
      '<form data-predownload action="' .
      $url . '" method="post" name="redirect"></form><script>setTimeout(function(){document.forms.redirect.submit()}, ' .
      ($delay ? $delay . "000" : 0) . ');</script>';
    print "<body>\n";
    print $script . "\n";

    if ($message) {
        print $message . "\n";
    }
    print "</body>\n";
    print '</html>';
}

sub theme_redirect_download
{
    if ($_[0] =~ /fetch.cgi/) {
        my $query = get_env('query_string');
        my $show  = $query =~ /show=1/ ? 1 : 0;
        my $delay = $_[0] =~ /unzip=1/ ? 1 : 0;
        my $zip   = $_[0] =~ /.zip/ ? 1 : 0;
        my $message;

        if ($delay) {
            $message = $theme_text{'theme_xhred_download_is_being_prepared'};
        }
        if (!$delay && !$show) {
            $message = $theme_text{'right_download_is_ready'};
        }

        theme_header_redirect_download($_[0], $delay, $message);

        return 1;
    } else {
        return 0;
    }
}

sub theme_js_redirect
{
    my ($url, $window) = @_;

    $window ||= "window";
    if ($url =~ /^\//) {
        $url = $gconfig{'webprefix'} . $url;
    }

    return
"$theme_text{'theme_xhred_global_redirecting'} <span class=\"loading-dots\"></span> <script type='text/javascript'>var v___theme_postponed_fetcher = setTimeout(function(){ get_pjax_content('"
      . quote_escape($url)
      . "');}, 3000);</script>\n";
}

sub theme_post_save_domain
{
    my ($d, $action) = @_;
    print '<script>';
    print 'theme_post_save=' . ($d->{'id'} ? $d->{'id'} : '-1') . '', "\n";
    print '</script>';
}

sub theme_post_save_domains
{
    my ($d, $action) = @_;
    print '<script>';
    print 'theme_post_save=0', "\n";
    print '</script>';
}

sub theme_post_save_server
{
    my ($s, $action) = @_;
    if ($action eq 'create' ||
        $action eq 'delete' ||
        !$done_theme_post_save_server++)
    {
        print '<script>';
        print 'theme_post_save=' . ($s->{'id'} ? $s->{'id'} : '-1') . '', "\n";
        print '</script>';
    }
}

sub theme_select_server
{
    my ($s) = @_;
    print '<script>';
    print 'theme_select_server=' . ($s->{'id'} ? $s->{'id'} : '0') . '', "\n";
    print '</script>';
}

sub theme_post_change_theme
{
    # Clear module modifications
    lib_csf_control('unload');

    # Remove error handler
    error_40x_handler(1);
}

sub theme_post_change_modules
{
    print '<script>';
    print 'theme_post_save=-1', "\n";
    print '</script>';
}

$main::cloudmin_no_create_links = 1;
$main::cloudmin_no_edit_buttons = 1;
$main::cloudmin_no_global_links = 1;

$main::mailbox_no_addressbook_button = 1;
$main::mailbox_no_folder_button      = 1;

$main::basic_virtualmin_menu          = 1;
$main::basic_virtualmin_domain        = 1;
$main::nocreate_virtualmin_menu       = 1;
$main::nosingledomain_virtualmin_mode = 1;

1;
