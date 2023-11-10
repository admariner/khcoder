package gui_window::noun_phrases;
use base qw(gui_window);
use mysql_hukugo;
use strict;
use Tk;

#------------------#
#   Window�򳫤�   #

sub _new{
	my $self = shift;
	$self->{win_obj}->title(
		$self->gui_jt(kh_msg->get('win_title')) # ʣ���θ��С���䥡�
	);

	# ����ȥ�ȸ����ܥ���Υե졼��
	my $fra4 = $self->{win_obj}->LabFrame(
		-label => 'Filter Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');
	my $fra4e = $fra4->Frame()->pack(-expand => 'y', -fill => 'x');

	my $e1 = $fra4e->Entry(
		-font => "TKFN",
		-background => 'white'
	)->pack(-expand => 'y', -fill => 'x', -side => 'left');
	$self->{win_obj}->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);
	$e1->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e1]);
	$e1->bind("<Key-Return>",sub{$self->search;});
	$e1->bind("<KP_Enter>",sub{$self->search;});

	my $sbutton = $fra4e->Button(
		-text => kh_msg->get('gui_window::hukugo->run'), # ����
		-font => "TKFN",
		-command => sub{$self->search;}
	)->pack(-side => 'right', -padx => '2');

	my $blhelp = $self->{win_obj}->Balloon();
	$blhelp->attach(
		$sbutton,
		-balloonmsg => '"ENTER" key',
		-font => "TKFN"
	);

	# ���ץ���󡦥ե졼��
	my $fra4i = $fra4->Frame->pack(-expand => 'y', -fill => 'x');

	$self->{optmenu_andor} = gui_widget::optmenu->open(
		parent  => $fra4i,
		pack    => {-anchor=>'e', -side => 'left', -padx => 2},
		options =>
			[
				[kh_msg->get('gui_window::word_search->or') , 'OR'], # OR����
				[kh_msg->get('gui_window::word_search->and'), 'AND'], # AND����
			],
		variable => \$self->{and_or},
	);

	$self->{optmenu_bk} = gui_widget::optmenu->open(
		parent  => $fra4i,
		pack    => {-anchor=>'e', -side => 'left', -padx => 12},
		options =>
			[
				[kh_msg->get('gui_window::word_search->part')  => 'p'], # ��ʬ����
				[kh_msg->get('gui_window::word_search->comp') => 'c'], # ��������
				[kh_msg->get('gui_window::word_search->forw') => 'z'], # ��������
				[kh_msg->get('gui_window::word_search->back') => 'k'] # ��������
			],
		variable => \$self->{s_mode},
	);

	# ���ɽ����ʬ
	my $fra5 = $self->{win_obj}->LabFrame(
		-label => 'List (Top 500)',
		-labelside => 'acrosstop',
		-borderwidth => 2
	)->pack(-expand=>'yes',-fill=>'both');
	
	my $hlist_fra = $fra5->Frame()->pack(-expand => 'y', -fill => 'both');

	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 2,
		-padx             => 2,
		-background       => 'white',
		-selectforeground   => $::config_obj->color_ListHL_fore,
		-selectbackground   => $::config_obj->color_ListHL_back,
		-selectborderwidth  => 0,
		-highlightthickness => 0,
		-selectmode       => 'extended',
		#-height           => 20,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => kh_msg->get('gui_window::hukugo->h_huku')); # ʣ���
	$lis->header('create',1,-text => kh_msg->get('gui_window::hukugo->h_freq')); # �и���

	$fra5->Button(
		-text => kh_msg->gget('copy'), # ���ԡ�
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub {gui_hlist->copy($self->{list});}
	)->pack(-side => 'right');

	$self->{conc_button} = $fra5->Button(
		-text => kh_msg->get('gui_window::hukugo->whole'), # ��ʣ���Υꥹ��
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub {$self->open_full_list;}
	)->pack(-side => 'left');
	
	$self->{list}  = $lis;
	$self->{entry}   = $e1;

	return $self;
}

#----------#
#   �¹�   #

sub search{
	my $self = shift;

	# �����¹�
	my $result = mysql_nounphrases->search(
		query  => $self->gui_jg( $self->{entry}->get ),
		method => $self->gui_jg( $self->{and_or} ),
		mode   => $self->gui_jg( $self->{s_mode} ),
	);

	# ���ɽ��
	my $numb_style = $self->{list}->ItemStyle(
		'text',
		-anchor => 'e',
		-background => 'white',
		-font => "TKFN"
	);
	my $row = 0;
	$self->{list}->delete('all');

	foreach my $i (@{$result}){
		my $cu = $self->{list}->add($row,-at => "$row");
		$self->{list}->itemCreate(
			$cu,
			0,
			-text  => $self->gui_jchar($i->[0]),
		);
		$self->{list}->itemCreate(
			$cu,
			1,
			-text  => $i->[1],
			-style => $numb_style
		);
		++$row;
	}

}

sub open_full_list{
	my $self = shift;
	my $debug = 1;

	my $target_csv = $::project_obj->file_NounPhrases;
	gui_OtherWin->open($target_csv);
}

sub start{
	my $self = shift;
	$self->search;
	$self->{entry}->focus;
}

#--------------#
#   ��������   #

sub win_name{
	return 'w_noun_phrases';
}
1;